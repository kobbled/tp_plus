namespace Math
  M_PI := 3.14159

  inline def arclength(ang, rad) : numreg
    return(ang*rad*M_PI/180)
  end

  inline def arcangle(len, rad) : numreg
    return(len/rad*180/M_PI)
  end
end
