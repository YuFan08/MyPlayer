-- 智能 Esc 逻辑
-- 第一下：退出全屏/恢复窗口大小
-- 第二下：最小化

function smart_esc_handler()
    local fullscreen = mp.get_property_bool("fullscreen")
    local maximized = mp.get_property_bool("window-maximized")

    if fullscreen then
        mp.set_property("fullscreen", "no")
    elseif maximized then
        mp.set_property("window-maximized", "no")
    else
        mp.set_property("window-minimized", "yes")
        mp.set_property_bool("pause", true)  -- 最小化时暂停播放
    end
end

-- 导出函数给快捷键调用
mp.add_key_binding(nil, "smart_esc", smart_esc_handler)
