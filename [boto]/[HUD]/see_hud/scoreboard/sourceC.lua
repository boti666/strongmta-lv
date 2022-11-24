_tocolor = tocolor
function tocolor(r, g, b, a)
    if r == 124 and g == 197 and b == 118 then
        r, g, b = 61, 122, 188
    end
    return _tocolor(r, g, b, a)
end

_dxDrawText = dxDrawText
function dxDrawText(text, ...)
    --return _dxDrawText(string.gsub((string.gsub(text, "#7cc576", "#3d7abc")), "#7CC576", "#3d7abc"), ...)
    return _dxDrawText(string.gsub(string.gsub((string.gsub(text, "#7cc576", "#3d7abc")), "See#3d7abcMTA v3 scoreboard", "Strong#3d7abcMTA scoreboard"), "#7CC576", "#3d7abc"), ...)
end
