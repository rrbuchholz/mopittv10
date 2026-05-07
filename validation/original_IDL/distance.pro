function distance, lat1, lon1, lat2, lon2

      pi = 4.0*atan(1.D) 
      re = 6378.145
      epsilon=1.0e-8

      t1 = lat1*pi/180.0
      n1 = lon1*pi/180.0
      t2 = lat2*pi/180.0
      n2 = lon2*pi/180.0

      if (n2 - n1 gt pi) then begin
        if (n1 gt pi) then begin
          n1 = n1 - 2.0*pi
        endif else begin
          if (n2 gt pi) then begin
            n2 = n2 - 2.0*pi
          endif
        endelse
      endif

      if (abs(t2) lt abs(t1)) then begin
        tmp = t1
        t1 = t2
        t2 = tmp  
      endif

      theta = pi/2.0 - abs(t2)
      phi = abs(n2 - n1) 
      b = abs(t2 - t1) 

      if (abs(theta) lt epsilon) then begin

        c = b

      endif else begin

        arg = cos(theta)*cos(theta) + sin(theta)*sin(theta)*cos(phi)
        if (abs(arg) lt 1.0) then begin
          a = acos(arg)
        endif else begin
          a = 0.0
        endelse

        ac = pi - acos(tan(a/2.0)/tan(theta))
        arg = cos(a)*cos(b) + sin(a)*sin(b)*cos(ac) 

        if (arg ne 1.0) then begin
          c = acos(arg)
        endif else begin
          c = 0.0
        endelse

      endelse

      dist = re*c

return, dist

end

