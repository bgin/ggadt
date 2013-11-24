MODULE SPHERE

	USE, INTRINSIC :: ISO_C_BINDING
	USE PARAMS
	SAVE
	COMPLEX(C_DOUBLE_COMPLEX) :: DELM = CMPLX(IOR_RE, IOR_IM)

	CONTAINS

	FUNCTION PHI_SPHERE(X,Y,Z,K)
		IMPLICIT NONE
		REAL, INTENT(IN) :: X,Y,Z,K
		REAL :: R, L
		COMPLEX(C_DOUBLE_COMPLEX) :: PHI_SPHERE

		R = SQRT(X*X + Y*Y)
		L = SQRT(GRAIN_A*GRAIN_A - R*R)
		PHI_SPHERE = (0,0)

		IF (R < GRAIN_A) THEN 
			IF (Z < L .AND. Z > -L) THEN 
				PHI_SPHERE = K*DELM*(Z+L)
			ELSE IF (Z > L) THEN
				PHI_SPHERE = K*DELM*(2*L)
			ELSE
				PHI_SPHERE = (0,0)
			END IF
		END IF
	END FUNCTION PHI_SPHERE

	FUNCTION SHADOW_SPHERE(X,Y,Z,K)
		IMPLICIT NONE
		REAL, INTENT(IN) :: X,Y,Z,K
		COMPLEX(C_DOUBLE_COMPLEX) :: SHADOW_SPHERE
		SHADOW_SPHERE = 1-EXP( (0.0,1.0)*PHI_SPHERE(X,Y,Z,K) )
		
	END FUNCTION SHADOW_SPHERE

END MODULE SPHERE