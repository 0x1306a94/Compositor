# Feature: Camera Raw Filter

The description below uses the default **en-US interface** for **Filter > Camera Raw Filter…**. Adobe calls the panel **Curve**, singular. The current Filter also normally includes **Geometry**, which is missing from the initial list.

## Overall window layout

| Region                | Contents                                                                                                 |
| --------------------- | -------------------------------------------------------------------------------------------------------- |
| Top bar               | Camera Raw title, document information when available, window/full-screen controls, and an options menu. |
| Main center-left area | A large live image preview on a neutral dark-gray canvas. It occupies most of the window.                |
| Right side            | Histogram, image/readout information, tool selector, and the vertically scrollable Edit panel.           |
| Bottom of preview     | Zoom controls, fit/100% viewing commands, preview comparison controls, and before/after options.         |
| Bottom-right footer   | **Cancel** and **OK** buttons.                                                                           |

Unlike the full Camera Raw file-opening workflow, the Filter dialog does not provide the normal **Save Image**, **Open Image**, **Done**, workflow-output, Crop, Rotate, or Snapshot features.

### Standard control anatomy

Most adjustment rows use the same visual structure:

1. The control name appears at the left.
2. A horizontal slider track occupies the center.
3. A draggable thumb indicates the current value.
4. A numeric value field appears at the far right.
5. Double-clicking the slider thumb resets the control to its default value.
6. The value can normally be dragged, typed, or changed with the arrow keys.
7. Hovering the pointer over any field must display a short tooltip that clearly and simply explains what the field does. This applies to sliders, slider thumbs, numeric value fields, drop-down menus, checkboxes, buttons, and other interactive controls.

Each major panel has:

* A disclosure chevron at the left.
* The panel name.
* A panel visibility or preview eye at the right after adjustments exist.
* Occasionally, a reset or overflow menu.
* Indented secondary controls that appear when a main effect is enabled.

The entire adjustment column scrolls vertically.

## Upper-right area

### Histogram

The histogram occupies the top of the right column.

* It uses overlapping red, green, and blue ribbons.
* It is a single live RGB histogram, not a set of separate histograms.
* Its horizontal axis represents the image’s tonal distribution.
* From left to right, it approximately corresponds to **Blacks**, **Shadows**, **Midtones**, **Highlights**, and **Whites**.
* These tonal regions do not need to be permanently labeled on the graph, but their order and visual meaning must remain clear.
* **Exposure** mainly shifts the overall distribution and strongly affects the midtones.
* **Contrast** expands or compresses the distribution.
* Exposure and Contrast are adjustments, not separate tonal regions of the histogram.
* The **Blacks**, **Shadows**, **Highlights**, and **Whites** sliders in the Light panel should visibly affect their corresponding portions of the histogram.
* The **Shadow Clipping Indicator** is in the upper-left corner.
* The **Highlight Clipping Indicator** is in the upper-right corner.
* Enabling shadow clipping places a blue overlay over clipped shadows in the preview.
* Enabling highlight clipping places a red overlay over clipped highlights.
* The histogram updates continuously as adjustments change.
* RGB or Lab values for the pixel under the pointer can appear below it.
* In Camera Raw 18.6, the histogram can also be changed to a **Vectorscope** through its context menu.

Camera metadata such as ISO, focal length, aperture, and shutter speed may be displayed below the histogram when that information is available. Because Camera Raw Filter receives an already-rendered Photoshop layer, some metadata may be unavailable.

### Edit header and profile

Below the histogram is the **Edit** area.

The upper portion normally contains:

* **Auto** — automatically calculates a general tone and color adjustment.
* **B&W** — converts the processing mode to black and white.
* **Profile** drop-down.
* **Browse Profiles** icon.
* A conditional **Amount** slider for profiles that support variable strength, such as Creative or Adaptive profiles.

The collapsible adjustment panels follow underneath.

## Default adjustment-panel stack

The current split-panel interface is organized approximately as follows:

1. **Light**
2. **Color**
3. **Effects**
4. **Curve**
5. **Color Mixer**
6. **Color Grading**
7. **Detail**
8. **Optics**
9. **Geometry**
10. **Calibration**

Feature-dependent panels such as **Lens Blur** may also be present in supported configurations.

---

## 1. Light

The **Light** panel contains the primary tonal controls, arranged vertically:

1. **Exposure**
2. **Contrast**
3. **Highlights**
4. **Shadows**
5. **Whites**
6. **Blacks**

Their functions are:

* **Exposure** changes overall image brightness in stop-like increments.
* **Contrast** expands or compresses tonal separation, mainly around the midtones.
* **Highlights** targets the bright tonal region.
* **Shadows** targets the dark tonal region.
* **Whites** changes the white point and highlight clipping.
* **Blacks** changes the black point and shadow clipping.

Holding **Alt** on Windows or **Option** on macOS while moving certain tonal sliders shows a temporary clipping visualization in the main preview.

## 2. Color

The upper part of the **Color** panel is the white-balance group:

1. **White Balance** drop-down
2. **White Balance Selector** eyedropper
3. **Temperature**
4. **Tint**

The global saturation controls follow:

5. **Vibrance**
6. **Saturation**

The Color sliders must use colored gradient tracks to communicate the direction of each adjustment:

* **Temperature:** blue on the left, transitioning to yellow on the right.
* **Tint:** green on the left, transitioning to magenta on the right.
* **Vibrance:** gray on the left, transitioning to red on the right.
* **Saturation:** gray on the left, transitioning to red on the right.

The slider thumb must remain clearly visible over each gradient. The gradient must not reduce the readability of the current value or the control’s hover tooltip.

Important Filter-specific behavior:

* On a rendered Photoshop layer, **Temperature** is generally a relative cool-to-warm adjustment rather than a true raw-file Kelvin setting.
* Raw-only white-balance presets may therefore be absent.
* **Tint** moves between green and magenta.
* **Vibrance** preferentially affects less-saturated colors and protects already-saturated colors and skin tones.
* **Saturation** changes all colors more uniformly.

When **B&W** is enabled, the color-processing interface changes and the Color Mixer becomes a black-and-white channel mixer.

## 3. Effects

The **Effects** panel contains global texture and atmospheric controls:

1. **Texture**
2. **Clarity**
3. **Dehaze**

It also contains expandable or subordinate effect groups.

### Glow

* **Glow** — master amount.
* **Style** drop-down:

  * **Diffusion**
  * **Bloom**
  * **Halation**
* **Range**
* **Spread**
* **Warmth**

The subordinate controls become relevant once Glow is increased. **Warmth** operates differently for Halation than for Diffusion or Bloom.

### Vignette / Post Crop Vignetting

* **Amount**
* **Midpoint**
* **Roundness**
* **Feather**
* **Highlights**

Depending on the exact interface configuration, a **Style** choice may also appear:

* **Highlight Priority**
* **Color Priority**
* **Paint Overlay**

The secondary controls are normally indented below **Amount**. **Highlights** is primarily relevant when the vignette darkens the image edges.

### Grain

* **Amount**
* **Size**
* **Roughness**

The grain should be evaluated at or near 100% zoom because its apparent size changes with preview magnification.

## 4. Curve

The **Curve** panel is graph-based rather than a simple list of sliders.

A row of mode and channel buttons selects:

1. **Parametric Curve**
2. **Point Curve / RGB Channels**
3. **Red Channel**
4. **Green Channel**
5. **Blue Channel**

### Parametric Curve

The graph contains tonal-region dividers along its lower edge. Beneath the graph are:

* **Highlights**
* **Lights**
* **Darks**
* **Shadows**

Moving a divider changes the tonal range controlled by the neighboring sliders.

A **Targeted Adjustment Tool** can be activated and dragged directly over the image. Camera Raw determines which tonal region is under the pointer and moves the relevant curve controls.

### Point Curve

The Point Curve view contains:

* Editable curve graph.
* Control points placed directly on the curve.
* Input/output value feedback.
* A curve preset menu such as:

  * **Linear**
  * **Medium Contrast**
  * **Strong Contrast**
* **Refine Saturation** for the composite RGB curve.

The composite RGB curve modifies luminance and contrast. The individual red, green, and blue curves can alter both tone and color balance.

## 5. Color Mixer

The upper part of this panel provides editing-mode controls, generally including **Mixer** and **Point Color**.

### Mixer: HSL view

The HSL view has three tabs:

* **Hue**
* **Saturation**
* **Luminance**

Each tab displays eight color-range sliders in this order:

1. **Reds**
2. **Oranges**
3. **Yellows**
4. **Greens**
5. **Aquas**
6. **Blues**
7. **Purples**
8. **Magentas**

A Targeted Adjustment Tool can be dragged directly over a color in the preview. Several neighboring color sliders may move simultaneously because real-world colors rarely belong to one channel exclusively.

### Mixer: Color view

The Color view presents a row or grid of eight colored swatches. Selecting one swatch exposes:

* **Hue**
* **Saturation**
* **Luminance**

These controls affect the selected color family.

### Point Color

The Point Color tab contains:

* Color-picker eyedropper.
* Up to eight saved color swatches.
* Selected-color field or visual color box.
* **Hue Shift**
* **Saturation Shift**
* **Luminance Shift**
* **Variance**
* **Range**
* Detailed **Hue Range**, **Saturation Range**, and **Luminance Range** controls.
* **Visualize Range** checkbox.

The range controls use either a horizontal range bar or paired end handles rather than a normal single-value slider.

### B&W Mixer

When B&W processing is enabled, the panel becomes **B&W Mixer**. It retains the eight color names, but each slider controls how bright that original color appears in the monochrome result.

## 6. Color Grading

A row of view buttons appears at the top:

* **Three-Way**
* **Shadows**
* **Midtones**
* **Highlights**
* **Global**

The Three-Way view displays three color wheels for Shadows, Midtones, and Highlights. In the individual views, one larger wheel is displayed.

For each tonal region:

* The angle around the wheel determines **Hue**.
* Distance from the center determines **Saturation**.
* A luminance control beneath or beside the wheel determines **Luminance**.
* Numeric Hue and Saturation values may be shown next to the wheel.

Below the wheels are:

* **Blending**
* **Balance**

**Blending** controls overlap between the three tonal regions. **Balance** shifts the overall weighting toward Shadows or Highlights.

## 7. Detail

The Detail panel should normally be judged at 100% zoom or higher.

### Sharpening

1. **Amount**
2. **Radius**
3. **Detail**
4. **Masking**

Holding Alt/Option while moving **Masking** displays a black-and-white edge mask:

* White areas receive sharpening.
* Black areas are protected.

### Manual Noise Reduction

1. **Luminance**
2. **Luminance Detail**
3. **Luminance Contrast**
4. **Color**
5. **Color Detail**
6. **Color Smoothness**

The secondary luminance controls may remain visually inactive until **Luminance** is raised above zero.

The Filter workflow does **not** provide the raw-file AI operations **Denoise**, **Raw Details**, or **Super Resolution**. These require opening a supported source through the full Camera Raw workflow.

## 8. Optics

The panel begins with automatic correction options:

* **Remove Chromatic Aberration**
* **Enable Lens Profile Corrections**

When a lens profile is enabled and metadata is available, the following fields may appear:

* **Setup**
* **Make**
* **Model**
* **Profile**
* **Distortion**
* **Vignetting**

The two amount sliders control the strength of the profile’s distortion and lens-vignetting correction.

### Manual/Defringe controls

The manual area can contain:

* **Distortion — Amount**
* Defringe eyedropper
* **Purple Amount**
* **Purple Hue** — dual-handle hue-range control
* **Green Amount**
* **Green Hue** — dual-handle hue-range control
* **Vignetting — Amount**
* **Vignetting — Midpoint**

Profile detection may be unavailable when the Photoshop layer no longer carries usable camera and lens metadata. Manual controls remain usable.

## 9. Geometry

Geometry is available in Camera Raw Filter even though the Crop and Rotate tools are not.

At the top is the **Upright** button row:

* **Off**
* **Auto**
* **Level**
* **Vertical**
* **Full**
* **Guided**

Below it are the manual transform controls:

1. **Projection**
2. **Vertical**
3. **Horizontal**
4. **Rotate**
5. **Aspect**
6. **Scale**
7. **Offset X**
8. **Offset Y**
9. **Constrain Crop**

**Guided** allows two or more alignment guides to be drawn directly over the live preview. The preview transforms interactively as the guides are positioned.

## 10. Calibration

The panel begins with:

* **Process** drop-down

For current images, the current process is normally **Version 6**.

The remaining controls are grouped as follows.

### Shadows

* **Tint**

### Red Primary

* **Hue**
* **Saturation**

### Green Primary

* **Hue**
* **Saturation**

### Blue Primary

* **Hue**
* **Saturation**

These controls modify the underlying interpretation of the RGB primaries. They are not equivalent to the eight perceptual color ranges in Color Mixer.

## Live image preview behavior

The main preview is not a static thumbnail. It is the active rendering surface for the Filter.

* Dragging a slider continuously re-renders the image.
* Typing a value updates the preview after the value is committed.
* Curve points update the preview while they are dragged.
* Targeted Adjustment tools use the pixel underneath the pointer to determine which tone or color controls to modify.
* Geometry guides and transforms update the image interactively.
* The histogram is recalculated as the preview changes.
* Shadow and highlight clipping overlays appear directly on the image.
* A panel’s eye control temporarily hides only that panel’s contribution.
* The global preview control compares the complete edited state with the state present when the Filter was opened.
* Before/After modes can show the two versions side by side or in a split view.
* Zooming and panning change only the view, not the image result.

The Photoshop document behind the modal window is not permanently modified during this preview:

* **Cancel** discards the Camera Raw Filter operation.
* **OK** renders the result onto the selected layer.
* If the layer was converted to a **Smart Object**, Camera Raw Filter is added as an editable **Smart Filter**.
* On a normal pixel layer, confirming the dialog applies the result destructively to that layer.

## Official Adobe references

* [What’s new in Photoshop desktop](https://helpx.adobe.com/photoshop/using/whats-new.html)
* [What’s new in Camera Raw](https://helpx.adobe.com/camera-raw/desktop/whats-new/whats-new.html)
* [Camera Raw workspace overview](https://helpx.adobe.com/camera-raw/desktop/get-started/overview-and-setup/introduction-camera-raw.html)
* [Camera Raw versus Camera Raw Filter](https://helpx.adobe.com/camera-raw/desktop/get-started/overview-and-setup/differences-camera-raw-camera-raw.html)
* [Color, tone, Curve, Color Mixer, and Color Grading](https://helpx.adobe.com/camera-raw/desktop/using/make-color-tonal-adjustments-camera.html)
* [Effects controls](https://helpx.adobe.com/camera-raw/desktop/edit-and-enhance-images/tone-and-color/vignette-grain-effects-camera-raw.html)
* [Detail controls](https://helpx.adobe.com/camera-raw/desktop/using/sharpening-noise-reduction-camera-raw.html)
* [Optics controls](https://helpx.adobe.com/camera-raw/desktop/using/correct-lens-distortions-camera-raw.html)
* [Geometry controls](https://helpx.adobe.com/camera-raw/desktop/edit-and-enhance-images/crop-rotate-and-geometry/automatic-perspective-correction-camera-raw.html)
