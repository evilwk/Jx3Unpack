function serialize(o) 
    if type(o) == "number" then 
        io.write(o) 
    elseif type(o) == "string" then 
        io.write(string.format("%q", o)) 
    elseif type(o) == "table" then 
        io.write("{\n") 
        for k,v in pairs(o) do 
	        io.write(" [") 
	        serialize(k) 
	        io.write("] = ") 
            serialize(v) 
            io.write(",\n") 
        end 
        io.write("}\n") 
    else 
        error("cannot serialize a " .. type(o)) 
    end 
end
	
function basicSerialize(o) 
    if type(o) == "number" then 
        return tostring(o) 
    else -- assume it is a string 
        return string.format("%q", o) 
    end 
end 
	
function save(name, value, saved) 
    saved = saved or {} -- initial value 
    io.write(name, " = ") 
    if type(value) == "number" or type(value) == "string" then 
        io.write(basicSerialize(value), "\n") 
    elseif type(value) == "table" then 
        if saved[value] then -- value already saved? 
            io.write(saved[value], "\n") -- use its previous name 
        else 
            saved[value] = name -- save name for next time 
            io.write("{}\n") -- create a new table 
            for k,v in pairs(value) do -- save its fields 
                local fieldname = string.format("%s[%s]", name, 
                basicSerialize(k)) 
                save(fieldname, v, saved) 
            end 
        end 
    else 
        error("cannot save a " .. type(value)) 
    end 
end

