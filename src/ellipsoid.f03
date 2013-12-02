MODULE ELLIPSOID

	USE, INTRINSIC :: ISO_C_BINDING
	USE PARAMS
	SAVE
	COMPLEX(C_DOUBLE_COMPLEX) :: DELM = CMPLX(IOR_RE, IOR_IM)
	REAL, DIMENSION(3) :: EULER_ANGLES
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

	FUNCTION CHORD_ELLIPSOID(POS,R)
		IMPLICIT NONE
		REAL :: CHORD_ELLIPSOID
		REAL :: D, temp
		REAL, DIMENSION(3) :: C
		REAL, INTENT(IN), DIMENSION(3,3) :: R
		REAL, INTENT(IN), DIMENSION(3) :: POS 
		INTEGER :: I,J,K,M


		C(1) = 0
		C(2) = 0
		C(3) = 0
		DO I=1,3
			temp = GRAIN_A(I)**(-2.0)
			C(1) = C(1) + temp*R(I,3)**2
			DO J=1,2
				C(2) = C(2) + 2*temp*R(I,3)*R(I,J)*POS(J)
				DO K=1,2
					C(3) = C(3) + temp*R(I,J)*R(I,K)*POS(J)*POS(K)
				END DO
			END DO
		END DO 

		
		C(3) = C(3) - 1 
		D    = C(2)*C(2)-4*C(1)*C(3)


		IF ((D .lt. 0) .or. (C(1) .eq. 0)) THEN
			CHORD_ELLIPSOID = 0
		ELSE
			CHORD_ELLIPSOID = SQRT(D)/C(1)
		END IF
	END FUNCTION CHORD_ELLIPSOID

	FUNCTION PHI_ELLIPSOID(X,Y,Z,K)
		IMPLICIT NONE
		REAL, INTENT(IN) :: X,Y,Z,K
		REAL, DIMENSION(3) :: POS 
		COMPLEX(C_DOUBLE_COMPLEX) :: PHI_ELLIPSOID
		EULER_ANGLES(1) = 0
		EULER_ANGLES(2) = 0
		EULER_ANGLES(3) = 0

		POS(1) = X
		POS(2) = Y
		POS(3) = Z

		PHI_ELLIPSOID = K*DELM*CHORD_ELLIPSOID(POS,ROT_MATRIX(EULER_ANGLES))
		
	END FUNCTION PHI_ELLIPSOID

	FUNCTION SHADOW_ELLIPSOID(X,Y,Z,K)
		IMPLICIT NONE
		REAL, INTENT(IN) :: X,Y,Z,K
		COMPLEX(C_DOUBLE_COMPLEX) :: SHADOW_ELLIPSOID
		SHADOW_ELLIPSOID = 1-EXP( (0.0,1.0)*PHI_ELLIPSOID(X,Y,Z,K) )
		
	END FUNCTION SHADOW_ELLIPSOID

END MODULE ELLIPSOID