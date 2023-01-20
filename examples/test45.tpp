use_utool 3
use_uframe 2

TP_GROUPMASK = "1,1,*,*,*"

foo := PR[1]
TERM := 100

linear_move.to(foo).at(500, 'mm/s').term(TERM)

position_data
{
  'positions' : [
    {
      'id' : 1,
      'mask' :  [{
        'group' : 1,
        'uframe' : 5,
        'utool' : 2,
        'config' : {
            'flip' : false,
            'up'   : true,
            'top'  : true,
            'turn_counts' : [0,0,0]
            },
        'components' : {
            'x' : -.590,
            'y' : -29.400,
            'z' : 1304.471,
            'w' : 78.512,
            'p' : 89.786,
            'r' : -11.595
            }
        },
        {
        'group' : 2,
        'uframe' : 5,
        'utool' : 2,
        'components' : {
            'J1' : 0.00
            }
        }]
    }
  ]
}
end