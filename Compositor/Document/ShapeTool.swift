import AppKit

nonisolated enum ShapeKind: String, CaseIterable, Sendable {
    case rectangle = "Rectangle"
    case ellipse = "Ellipse"
    /// The shape filling `rect`. A rectangle's corners round by `cornerRadius`, at most half its shorter
    /// side (so a large radius makes a pill); ellipses ignore it.
    func path(in rect: CGRect, cornerRadius: CGFloat = 0) -> CGPath {
        if self == .ellipse { return CGPath(ellipseIn: rect, transform: nil) }
        let radius = min(max(0, cornerRadius), rect.width / 2, rect.height / 2)
        guard radius > 0 else { return CGPath(rect: rect, transform: nil) }
        return CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    }
}

/// A shape being dragged out with the Shape tool, in whole document pixels.
struct ShapeDraft: Equatable {
    let kind: ShapeKind
    let anchor: CGPoint
    var rect: CGRect
    /// Document pixels, fixed when the drag starts; rectangles only.
    var cornerRadius: CGFloat = 0
}

extension EditorSession {
    /// Pixels one shape layer may hold, the same budget as an import.
    static let maxShapePixels = 100_000_000

    func beginShape(at point: CGPoint) {
        guard tool == .shape, canEditLayers, point.x.isFinite, point.y.isFinite else { return }
        let anchor = CGPoint(x: point.x.rounded(), y: point.y.rounded())
        shapeDraft = ShapeDraft(kind: shapeKind, anchor: anchor, rect: CGRect(origin: anchor, size: .zero),
                                cornerRadius: shapeKind == .rectangle ? CGFloat(shapeCornerRadius) : 0)
    }

    /// Shift makes a square or circle; Option grows the shape from its center, as in Photoshop.
    func dragShape(to point: CGPoint, square: Bool, fromCenter: Bool) {
        guard var draft = shapeDraft, point.x.isFinite, point.y.isFinite else { return }
        draft.rect = DragBox.rect(from: draft.anchor, to: point, square: square, fromCenter: fromCenter)
        shapeDraft = draft
    }

    func cancelShape() {
        if shapeDraft != nil { shapeDraft = nil }
    }

    /// Shift-U: the Shape tool switches between Rectangle and Ellipse.
    func toggleShapeKind() {
        cancelShape()
        shapeKind = shapeKind == .rectangle ? .ellipse : .rectangle
    }

    /// Fills the dragged shape with the foreground color on a new layer above the active one,
    /// in one undo step. A click without a drag makes nothing; the selection is left alone.
    func finishShape() {
        guard let draft = shapeDraft else { return }
        shapeDraft = nil
        let rect = draft.rect
        guard canEditLayers, document != nil, rect.width >= 1, rect.height >= 1 else { return }
        guard Int(rect.width) * Int(rect.height) <= Self.maxShapePixels else {
            brushError = "That shape is too large. A shape can cover up to 100 megapixels."
            return
        }
        do {
            let image = try Self.shapeImage(draft.kind, size: rect.size, color: foregroundColor, cornerRadius: draft.cornerRadius)
            addPixelLayer(image, at: rect.origin, name: nextShapeName(draft.kind), editName: draft.kind.rawValue,
                          dropsSelection: false)
        } catch { brushError = error.localizedDescription }
    }

    /// "Rectangle 1", "Ellipse 2", … skipping names already in the document.
    func nextShapeName(_ kind: ShapeKind) -> String {
        let names = Set(document?.layers.map(\.name) ?? [])
        var number = 1
        while names.contains("\(kind.rawValue) \(number)") { number += 1 }
        return "\(kind.rawValue) \(number)"
    }

    /// The shape filling its box, anti-aliased where it curves.
    static func shapeImage(_ kind: ShapeKind, size: CGSize, color: PaletteColor, cornerRadius: CGFloat = 0) throws -> CGImage {
        let context = try BrushRaster.context(width: Int(size.width), height: Int(size.height), mask: false)
        context.setFillColor(CGColor(srgbRed: color.red, green: color.green, blue: color.blue, alpha: 1))
        context.addPath(kind.path(in: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius))
        context.fillPath()
        guard let image = context.makeImage() else { throw ExportError.render }
        return image
    }
}
