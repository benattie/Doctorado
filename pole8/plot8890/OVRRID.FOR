C************************************************************************
C
C     SUBROUTINE OVRRID
C
C     An over ride routine to set device constants. Normally
C     this is a pass through NOP function.
C
C     FORTRAN
C
C     CALL OVRRID( model, den, asps, ndot, npwide, dxm, dym )
C
C     WHERE:
C
C          model = Model number passed to this routine.
C
C            den = Number of dpi in the Y direction.
C
C           asps = Aspect ratio XDOTS/YDOTS.  For example an Epson has
C                  60 dpi in the Y direction and 72 dpi in the X
C                  direction.  Thus, asps=1.2.
C
C           ndot = Total number of dots per scanline. (Y) direction.
C
C         npwide = Specify pen width in terms of minimum step size.
C
C            dxm = Maximum window size in X direction.
C
C            dym = Maximum window size in Y direction.  Strip size also!
C
C***********************************************************************
C
C     COPYRIGHT  1989,  PLOTWORKS, Inc., SAN DIEGO, CA
C
C***********************************************************************
C
C     History:
C
C     [1]:  5/Feb/89    First written.
C
C***********************************************************************
C
      SUBROUTINE OVRRID( MODEL, DEN, ASPS, NDOT, NPWIDE, DXM, DYM )
C
C       MODELS 64 AND 65: LASERJET 4 AT 600 DPI
C           USED WITH         CALL DFESCP(45,0)
C
      IF(MODEL.EQ.64.OR.MODEL.EQ.65) DEN = 600.0
C
C           PAINTJET  300 XL OVERRIDE OF DENSITY
C           USED WITH          CALL DFESCP(44,0)
C
C  MODELS   35: A SIZE, 300 DPI, BLACK AND WHITE
C           36: A SIZE, 300 DPI, COLOR
C           37: B SIZE, 300 DPI, BLACK AND WHITE
C           38: B SIZE, 300 DPI, COLOR
C
      IF( MODEL.GE.35.AND.MODEL.LE.38) DEN = 300.0
C...  End of subroutine
      RETURN
      END
