namespace PRTypes
  POSITION  := 1
  XYZWPR    := 2
  XYZWPREXT := 6
  JOINTPOS  := 9
end

type := DO[1]

case type
    when PRTypes::POSITION
        print('1')
    when PRTypes::XYZWPR
        print('2')
    when PRTypes::XYZWPREXT
        print('3')
    when PRTypes::JOINTPOS
        print('4')
end

def testfunc()
    using PRTypes
    type2 := DO[2]

    case type2
        when PRTypes::POSITION
            print('1')
        when PRTypes::XYZWPR
            print('2')
        when PRTypes::XYZWPREXT
            print('3')
        when PRTypes::JOINTPOS
            print('4')
    end 
end