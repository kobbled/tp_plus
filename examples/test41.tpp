foo := R[1]

if foo == 1
    message('foo == 1')
    warning('This is a warning')
else
    message('foo != 1')
end

@alarm

warning('This is another warning')