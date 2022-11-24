_tocolor = tocolor
function tocolor(r, g, b, a)
    if r == 124 and g == 197 and b == 118 then
        r, g, b = 61, 122, 188
    end
    return _tocolor(r, g, b, a)
end

_dxDrawText = dxDrawText
function dxDrawText(text, ...)
    return _dxDrawText(string.gsub((string.gsub(text, "#7cc576", "#bc873d")), "#7CC576", "#3d7abc"), ...)
end

_outputChatBox = outputChatBox
function outputChatBox(text, ...)
    return _outputChatBox(string.gsub(string.gsub((string.gsub(text, "#7cc576", "#3d7abc")), "SeeMTA", "StrongMTA"), "#7CC576", "#3d7abc"), ...)
end

--showMyName

addCommandHandler("asd",
	function ()
		adminNames = not adminNames
	end 
)