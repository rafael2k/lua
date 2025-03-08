-- Initialize the VGA mode (320x200 256-color mode)
vga_init(0x13)

-- Function to draw a filled rectangle
function draw_filled_rectangle(x, y, width, height, color)
    -- Loop through the height and width to plot each pixel in the rectangle
    for i = 0, width - 1 do
        for j = 0, height - 1 do
            plot_pixel(x + i, y + j, color)  -- Draw pixel at (x + i, y + j)
        end
    end
end

-- Draw a filled rectangle at position (50, 50) with width 100 and height 50, using color 15 (white)
draw_filled_rectangle(50, 50, 100, 50, 15)
draw_filled_rectangle(100, 100, 100, 50, 4)

vga_init(0x03)
