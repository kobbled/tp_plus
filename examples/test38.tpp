namespace ns1
  frame := UFRAME[1]
  var1 := R[10]
  ANALOG_M := 10.321

  inline def foobar(barreg)
    print('selected register')
    printnr(barreg)
  end
end

namespace Lam
  using ns1

  def set_params()
    var1 := LR[]

    power = 1000
    flowrate = 0.85
    var1 = speed

    Laser_Enable = on

    ns1::foobar(&power)
  end
end

var1 := R[123]
var2 := R[124]

use_uframe ns1::frame

ns1::var1 = ns1::ANALOG_M
var1 = Lam::power
var2 = Lam::flowrate
Lam::set_params()