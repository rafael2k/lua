-- Initialize the VGA mode (320x200 256-color mode)
vga_init(0x13)

-- Cube vertices (8 points in 3D space)
local cube = {
{-1, -1, -1}, {1, -1, -1}, {1, 1, -1}, {-1, 1, -1},
{-1, -1, 1}, {1, -1, 1}, {1, 1, 1}, {-1, 1, 1}
}

-- Cube edges (pairs of indices)
local edges = {
  {1, 2}, {2, 3}, {3, 4}, {4, 1}, -- Back face
  {5, 6}, {6, 7}, {7, 8}, {8, 5}, -- Front face
  {1, 5}, {2, 6}, {3, 7}, {4, 8} -- Connecting edges
}

local angleX, angleY = 0, 0 -- Rotation angles
local size = 40 -- Cube size
local fov = 3 -- Field of view

-- Function to rotate around X-axis
local function rotateX(x, y, z, angle)
  local cosA, sinA = math.cos(angle), math.sin(angle)
  return x, y * cosA - z * sinA, y * sinA + z * cosA
end

-- Function to rotate around Y-axis
local function rotateY(x, y, z, angle)
  local cosA, sinA = math.cos(angle), math.sin(angle)
  return x * cosA + z * sinA, y, -x * sinA + z * cosA
end

-- Function to project 3D point to 2D
local function project3D(x, y, z)
  local scale = fov / (fov + z) -- Perspective projection
  local screenX = x * scale * size + 160 -- Center at (160, 100)
  local screenY = y * scale * size + 100
  return screenX, screenY
end

while true do
-- Clear screen
   for x = 0, 319 do
    for y = 0, 199 do
      plot_pixel(x, y, 0) -- Black
    end
   end

   local transformed = {}

-- Rotate and project each vertex
   for i, v in ipairs(cube) do
     local x, y, z = v[1], v[2], v[3]

     -- Apply both rotations
     local rx, ry, rz = rotateX(x, y, z, angleX)
     local finalX, finalY, finalZ = rotateY(rx, ry, rz, angleY)

     -- Project after both rotations
     local screenX, screenY = project3D(finalX, finalY, finalZ)
     transformed[i] = {screenX, screenY} -- Store the transformed screen coordinates
   end

-- Draw cube edges
   for _, edge in ipairs(edges) do
      local p1, p2 = transformed[edge[1]], transformed[edge[2]]
      plot_line(p1[1], p1[2], p2[1], p2[2], 15)  -- White color
   end

-- Update rotation
   angleX = angleX + (5 / 100)
   angleY = angleY + (3 / 100)

-- Delay to control speed
-- delay(30)
end
