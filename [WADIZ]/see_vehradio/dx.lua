sx_, sy_ = guiGetScreenSize()

sx, sy = 1920, 1080
xm, ym = sx_/1920, sy_/1080


rectangle = function(x, y, w, h, clr)
    return dxDrawRectangle(x*xm, y*ym, w*xm, h*ym, clr)
end

text = function(txt, x, y, w, h, clr, scale, ...)
    return dxDrawText(txt, x*xm, y*ym, w*xm, h*ym, clr, scale*xm, scale*ym, ...)
end

image = function(x, y, w, h, src, rx, ry, rz, clr)
    return dxDrawImage(x*xm, y*ym, w*xm, h*ym, src, rx, ry, rz, clr)
end

isInZone = function(x, y, w, h)
	if not isCursorShowing() then return false end
    local cx, cy = getCursorPosition()
    cx, cy = cx * sx_, cy * sy_
    return (cx >= x*xm and cx <= x*xm+w*xm) and (cy >= y*ym and cy <= y*ym+h*ym)
end