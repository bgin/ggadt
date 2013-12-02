! Parameter file for GGADT.
MODULE PARAMS

SAVE


REAL, PARAMETER 				::	A_EFF		= 0.2	! Micrometers
REAL, PARAMETER					::	EPHOT		= 0.5	! keV
CHARACTER(LEN=30), PARAMETER 	::	GEOMETRY 	= 'SPHERES'

INTEGER, PARAMETER 				:: 	NGRID 		= 2048
REAL, PARAMETER 				:: 	PI			= 3.14159
REAL, PARAMETER 				::	BOX_WIDTH	= 32.0
REAL, PARAMETER 				::	IOR_IM		=  3.201E-3
REAL, PARAMETER 				:: 	IOR_RE		= -2.079E-3
REAL, dimension(3)				:: 	GRAIN_A 
LOGICAL, PARAMETER 				::	MPI_MODE 	= .FALSE.
CHARACTER(LEN=10), PARAMETER 	::  FFT_TYPE	= "FFTW"


! REAL, PARAMETER 				::	IOR_IM		= 
! REAL, PARAMETER 				:: 	IOR_RE		= 

! if GEOMETRY == GRID:
! ===============================================
! CHARACTER, PARAMETER		:: 	GRID_FILE 	= "ggadt_grid.dat"
! REAL, PARAMETER			::	

! if GEOMETRY == COLLECTION_OF_SPHERES
! CHARACTER, PARAMETER		:: SPHERES_FILE = "ggadt_spheres.dat"
! INTEGER, PARAMETER		:: 


CONTAINS
	FUNCTION ROT_MATRIX(EUL_ANG)
		IMPLICIT NONE
		REAL, DIMENSION(3), INTENT(IN) :: EUL_ANG
		REAL, DIMENSION(3,3) :: ROT_MATRIX
		ROT_MATRIX(1,1) =  COS(EUL_ANG(2))*COS(EUL_ANG(3))
		ROT_MATRIX(1,2) = -COS(EUL_ANG(1))*SIN(EUL_ANG(3))-SIN(EUL_ANG(1))*SIN(EUL_ANG(2))*COS(EUL_ANG(3))
		ROT_MATRIX(1,3) =  SIN(EUL_ANG(1))*SIN(EUL_ANG(3))-COS(EUL_ANG(1))*SIN(EUL_ANG(2))*SIN(EUL_ANG(3))

		ROT_MATRIX(2,1) =  COS(EUL_ANG(2))*SIN(EUL_ANG(3))
		ROT_MATRIX(2,2) =  COS(EUL_ANG(1))*COS(EUL_ANG(3))-SIN(EUL_ANG(1))*SIN(EUL_ANG(2))*SIN(EUL_ANG(3))
		ROT_MATRIX(2,3) = -SIN(EUL_ANG(1))*COS(EUL_ANG(3))-COS(EUL_ANG(1))*SIN(EUL_ANG(2))*SIN(EUL_ANG(3))

		ROT_MATRIX(3,1) =  SIN(EUL_ANG(2))
		ROT_MATRIX(3,2) =  SIN(EUL_ANG(1))*COS(EUL_ANG(2))
		ROT_MATRIX(3,3) =  COS(EUL_ANG(1))*COS(EUL_ANG(2))

	END FUNCTION ROT_MATRIX
END MODULE PARAMS