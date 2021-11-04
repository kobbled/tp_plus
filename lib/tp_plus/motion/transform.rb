require "matrix"

def rotx(rx)
  # 
  ct = Math.cos(rx)
  st = Math.sin(rx)
  return Matrix[[1,0,0,0],[0,ct,-st,0],[0,st,ct,0],[0,0,0,1]]
end

def roty(ry)
  # 
  ct = Math.cos(ry)
  st = Math.sin(ry)
  return Matrix[[ct,0,st,0],[0,1,0,0],[-st,0,ct,0],[0,0,0,1]]
end

def rotz(rz)
  # 
  ct = Math.cos(rz)
  st = Math.sin(rz)
  return Matrix[[ct,-st,0,0],[st,ct,0,0],[0,0,1,0],[0,0,0,1]]
end

def transl(tx, ty=nil , tz=nil )
  # 
  if !ty 
    xx = tx[0]
    yy = tx[1]
    zz = tx[2]
  else
    xx = tx
    yy = ty
    zz = tz
  end
  return Matrix[[1,0,0,xx],[0,1,0,yy],[0,0,1,zz],[0,0,0,1]]
end

def Offset(target_pose, x, y, z, rx=0 , ry=0 , rz=0 )
  transl(x, y, z) * rotx(rx * Math::PI/180) * roty(ry * Math::PI/180) * rotz(rz * Math::PI/180) * target_pose
end

def pose_2_xyzrpw(h)
  # 
  x = h[0,3]
  y = h[1,3]
  z = h[2,3]
  if (h[2,0] > (1.0 - 1e-10))
    p = (-Math::PI)/2
    r = 
    w = Math.atan2(-h[1,2],h[1,1])
  else
    if h[2,0] < -1.0 + 1e-10
      p = Math::PI/2
      r = 0
      w = Math.atan2(h[1,2],h[1,1])
    else
      p = Math.atan2(-h[2,0],Math.sqrt(h[0,0]*h[0,0]+h[1,0]*h[1,0]))
      w = Math.atan2(h[1,0],h[0,0])
      r = Math.atan2(h[2,1],h[2,2])  
    end
  end

  [x, y, z, r*180/Math::PI, p*180/Math::PI, w*180/Math::PI]
end

def xyzrpw_2_pose(xyzrpw)
  # 
  x,y,z,r,p,w = xyzrpw
  a = r*Math::PI/180
  b = p*Math::PI/180
  c = w*Math::PI/180
  ca = Math.cos(a)
  sa = Math.sin(a)
  cb = Math.cos(b)
  sb = Math.sin(b)
  cc = Math.cos(c)
  sc = Math.sin(c)
  
  Matrix[[cb * cc, ((cc * sa) * sb) - (ca * sc), (sa * sc) + ((ca * cc) * sb), x], [cb * sc, (ca * cc) + ((sa * sb) * sc), ((ca * sb) * sc) - (cc * sa), y], [-sb, cb * sa, ca * cb, z], [0,0,0,1]]
end

def Pose(xyzrpw)
  # 
  x,y,z,rx,ry,rz = xyzrpw
  srx = Math.sin(rx)
  crx = Math.cos(rx)
  sry = Math.sin(ry)
  cry = Math.cos(ry)
  srz = Math.sin(rz)
  crz = Math.cos(rz)
  
  Matrix[[cry * crz, (-cry) * srz, sry, x], [(crx * srz) + ((crz * srx) * sry), (crx * crz) - ((srx * sry) * srz), (-cry) * srx, y], [(srx * srz) - ((crx * crz) * sry), (crz * srx) + ((crx * sry) * srz), crx * cry, z], [0,0,0,1]]
end