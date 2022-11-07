namespace ns1
    inline def calc_offset(num) : numreg
        return(4.53+3.13*Mth::ln(num))
    end
end

local := R[70..80]

var1 := R[1]
var2 := R[2]

var1 = 10

var2 = ns1::calc_offset(var1)
