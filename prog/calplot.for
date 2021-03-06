c************************************************************************
	program calplot
	implicit none
c
c= calplot -- Plot flux of primary calibrators
c& rjs
c: utility
c+
c	CALPLOT plots the flux of primary calibrators as a function
c	of frequency.
c@ source
c	The source to be plotted. No default.
c@ xrange
c	This gives two numbers, being the frequency range to plot, in GHz.
c	The default is 4.7,4.9.
c@ stokes
c	The Stokes parameters to be plotted. The default is to plot
c	only I.
c@ options
c	"cursor"   This activates the cursor, and returns the flux density 
c	  for each Stokes at the frequency specified by the x-location 
c	  of the cursor. Use right button (or 'X') to exit.
c@ device
c	PGPLOT device. No default.
c--
c  History:
c    rjs  19mar93 Derived from PARAPLOT.
c    nebk 01mar95 Allow smaller ranges
c    nebk 24may95 Add options=cursor
c    rjs  23aug96 Support plotting multiple sources.
c    rjs  28sep98 Print out flux at mid frequency.
c
c  Bugs:
c   * Perfect?
c------------------------------------------------------------------------
	character version*(*)
	integer NPTS,MAXPOL,NCOL,MAXSRC
	parameter(version='CalPlot: version 28-Sep-98')
	parameter(NPTS=257,MAXPOL=4,NCOL=12,MAXSRC=32)
c
	character source(MAXSRC)*32,device*32,line*80,stokes*4
	integer npol,pol(MAXPOL),length,ierr,cols(NCOL),i,j,k,nsrc
	real x(NPTS),y(NPTS,MAXPOL,MAXSRC),xrange(2)
	real xlo,xhi,ylo,yhi,delta,maxv,sdf
	double precision freq(NPTS)
        logical cursor
c
c  Externals.
c
	integer pgbeg,PolsP2C,len1
	logical keyprsnt
	character PolsC2P*2
c
	data cols/1,7,2,5,3,4,6,8,9,10,11,12/
c
	call output(version)
	call keyini
	call mkeya('source',source,MAXSRC,nsrc)
	if(nsrc.eq.0)call bug('f','A source must be given')
	call keya('stokes',stokes,'i')
	call keyr('xrange',xrange(1),4.7)
	call keyr('xrange',xrange(2),xrange(1))
	if(xrange(2).lt.xrange(1).or.xrange(1).le.0)
     *	  call bug('f','Bad frequency range')
	if(xrange(2).eq.xrange(1))then
	  xrange(1) = 0.95*xrange(1)
	  xrange(2) = 1.05*xrange(2)
	endif
c
	npol = 0
	dowhile(stokes.ne.' '.and.npol.lt.MAXPOL)
	  npol = npol + 1
	  pol(npol) = PolsP2C(stokes)
	  call keya('stokes',stokes,' ')
	enddo
	if(keyprsnt('stokes'))
     *	  call bug('f','Too many Stokes parameters given')
	call keya('device',device,' ')
        call options(cursor)
	call keyfin
c
c  Get information about the source.
c
	sdf = (xrange(2) - xrange(1)) / (NPTS-1)
	do i=1,NPTS
	  freq(i) = xrange(1) + sdf*(i-1)
	  x(i) = freq(i)
	enddo
c
	call output('------------+-------+--------+--------+')
	call output('Source       Stokes   Freq     Flux')
	call output('                      (GHz)    (Jy)')      
	call output('------------+-------+--------+--------+')
	do j=1,nsrc
	  do i=1,npol
	    stokes = PolsC2P(pol(i))
	    call lcase(stokes)
	    call CalStoke(source(j),stokes,freq,y(1,i,j),NPTS,ierr)
	    write(line,'(a16,a1,f10.3,f10.3)')source(j),stokes,
     *				freq(NPTS/2+1),y(NPTS/2+1,i,j)
	    call output(line)
	    if(ierr.eq.2)call bug('f','Unknown source')
	    if(ierr.eq.1)call bug('w','Extrapolation being used')
	  enddo
	enddo
c
c  Form the plot label.
c
	line = 'Stokes='
	length = len1(line)
	do i=1,npol
	  stokes = PolsC2P(pol(i))
	  line(length+1:) = stokes
	  length = len1(line) + 1
	  line(length:length) = ','
	enddo
	line(length:) = '; Source='
	length = len1(line)
	do i=1,nsrc
	  line(length+1:) = source(i)
	  length = len1(line) + 1
	  line(length:length) = ','
	enddo
	length = length - 1
c
c  Determine the plot ranges.
c
	delta = 0.05*(xrange(2)-xrange(1))
	if(delta.le.1e-5*xrange(2)) delta = 0.1*xrange(2)
	xlo = xrange(1) - delta
	xhi = xrange(2) + delta
c
	ylo = y(1,1,1)
	yhi = ylo
	do k=1,nsrc
	  do j=1,npol
	    do i=1,NPTS
	      ylo = min(ylo,y(i,j,k))
	      yhi = max(yhi,y(i,j,k))
	    enddo
	  enddo
	enddo
	delta = 0.05*(yhi - ylo)
	maxv = max(abs(yhi),abs(ylo))
	if(delta.le.1e-5*maxv)delta = 0.01*maxv
	if(delta.eq.0) delta = 1
	ylo = ylo - delta
	yhi = yhi + delta
c
c  Do the plotting.
c
	if(device.ne.' ')then
	  if(pgbeg(0,device,1,1).ne.1)then
	    call pgldev
	    call bug('f','Error opening graphics device')
	  endif
	  call pgpage
          call pgvstd
	  call pgswin(xlo,xhi,ylo,yhi)
	  call pgtbox('BCNST',0.,0,'BCNST',0.,0)
	  do j=1,nsrc
	    do i=1,npol
	      call pgsci(cols(mod(i-1,NCOL)+1))
	      call pgline(npts,x,y(1,i,j))
	    enddo
	  enddo
	  call pgsci(1)
	  call pglab('Frequency (GHz)','Flux (Jy)',line(1:length))
          if (cursor) call curstk(npol, pol, source)
	  call pgend
	endif
	end
c
c
      subroutine options (cursor)
      implicit none
c
      logical cursor
cc
      integer maxopt
      parameter (maxopt = 1)
c
      character opshuns(maxopt)*8
      logical present(maxopt)
      data opshuns /'cursor'/
c-----------------------------------------------------------------------
      call optcg ('options', opshuns, present, maxopt)
c
      cursor = present(1)
c
      end
c
c
      subroutine curstk (npol, pol, source)
c-----------------------------------------------------------------------
c Read cursor location and get Flux Density for each Stokes
c
c-----------------------------------------------------------------------
      implicit none
      integer npol, pol(npol)
      character source*(*)
cc
      character line*80, cch*1, stokes*1
      integer length, rlen, i, ierr
      real xx, yy, yyy
c
      integer len1
      character PolsC2P*2
c-----------------------------------------------------------------------
      line = 'Freq, Flux Density ('
      rlen = len1(line) + 1             
      do i = 1, npol
        line(rlen:rlen) = PolsC2P(pol(i))
        rlen = rlen + 1
      end do
      line(rlen:) = ') = '
      rlen = rlen + 4
c            
      cch=' '
      do while (cch.ne.'X' .and. cch.ne.'x')
        call pgcurse (xx,yy,cch)
        if (cch.ne.'X' .and. cch.ne.'x') then
          length = rlen
          write (line(length:), 40) xx
40        format (f8.4, ',  ')
          length = len1(line) + 3
c
          do i=1,npol
            stokes = PolsC2P(pol(i))
            call lcase(stokes)
            call calstoke(source,stokes,dble(xx),yyy,1,ierr)
            write (line(length:),50) yyy
50          format (f6.3, ', ')
            length = length + 8
c
            call pgpt (1, xx, yyy, 2)
          enddo
          length = len1(line) - 1
          call output (line(1:length))
        end if
      end do
c
      end


