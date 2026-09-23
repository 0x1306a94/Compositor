import CoreGraphics

/// The size and memory ceilings a document is held to, in one place.
///
/// These were repeated as literals in the editor, the renderer, the importers and the exporters,
/// so they could not be reasoned about or changed together. Two separate ideas had also collapsed
/// onto the same number: how large a *single* surface may be, and how much raster a *whole
/// document* may hold across all of its layers. Those are not the same budget. A 58-megapixel
/// print banner carrying 29 layers is an ordinary Photoshop document, and it needs far more than
/// one surface's worth of allowance even though no single surface in it is unusual.
///
/// Both pixel ceilings stay below `maxSide * maxSide`, so a square at `maxSide` is still rejected
/// as oversized. Several tests express "too large" that way, and it is the largest area the side
/// limit can describe.
nonisolated enum DocumentLimits {
    /// Longest side, in pixels, of any canvas, layer, mask or generated surface.
    static let maxSide = 30_000

    /// `maxSide` for the paths that measure in CGFloat.
    static let maxSideExtent = CGFloat(maxSide)

    /// Largest single surface: a canvas, an export, a filter target, an adjustment or mask render.
    /// At RGBA8 this caps one allocation at roughly 2 GB.
    static let maxSurfacePixels = 512_000_000

    /// `maxSurfacePixels` for the paths that measure in CGFloat.
    static let maxSurfaceExtent = CGFloat(maxSurfacePixels)

    /// Total imported raster one document may hold, summed across every layer and mask. Only
    /// documents that genuinely contain this much ever reach it, so the ceiling costs nothing to
    /// the small documents that never approach it.
    static let documentPixelBudget = 800_000_000

    /// The two ceilings as megapixels, for the messages that quote them back to the reader.
    static var maxSurfaceMegapixels: Int { maxSurfacePixels / 1_000_000 }
    static var documentBudgetMegapixels: Int { documentPixelBudget / 1_000_000 }
}
