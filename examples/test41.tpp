inline def outer()
 flg := F[5]
 flg2 := F[10]
 flg3 := F[10]
 
  if !flg
    func1()
    #goto powder bottle
    if flg2
      # positioner bottle
      func2()
    elsif flg3
      # headstock bottle
      func3()
    end

    flg2 = off
    flg3 = off
  end
end

outer()