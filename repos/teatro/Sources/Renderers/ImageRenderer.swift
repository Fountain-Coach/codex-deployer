#if canImport(Cairo)
import Cairo
#endif

public struct ImageRenderer {
    public static func renderToPNG(_ view: Renderable, to path: String = "output.png") {
#if canImport(Cairo)
        let surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 800, 600)
        let cr = cairo_create(surface)

        cairo_set_source_rgb(cr, 1, 1, 1)
        cairo_paint(cr)

        cairo_set_source_rgb(cr, 0, 0, 0)
        cairo_select_font_face(cr, "monospace", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
        cairo_set_font_size(cr, 16)

        let lines = view.render().components(separatedBy: "\n")
        for (i, line) in lines.enumerated() {
            cairo_move_to(cr, 10, Double(30 + i * 20))
            cairo_show_text(cr, line)
        }

        cairo_surface_write_to_png(surface, path)
        cairo_destroy(cr)
        cairo_surface_destroy(surface)
#else
        // Fallback stub for environments without Cairo
        try? view.render().write(toFile: path + ".txt", atomically: true, encoding: .utf8)
#endif
    }
}
