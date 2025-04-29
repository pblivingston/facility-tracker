local re = re
local d2d = d2d
local imgui = imgui

re.on_draw_ui(function()
    if imgui.tree_node("Screen Resolution") then
		local screen_w, screen_h = d2d.surface_size()
        imgui.text("Width: " .. tostring(screen_w))
        imgui.text("Height: " .. tostring(screen_h))
        imgui.tree_pop()
    end
end)
