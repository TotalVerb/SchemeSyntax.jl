function expandmodule(name::Symbol, body...)
    Expr(:module, true, name, Expr(:block, body...))
end

function expandexport(exports::Symbol...)
    Expr(:export, exports...)
end
