module spheres

	use, intrinsic :: iso_c_binding
	use common_mod
	use sphere
	save
	integer :: nspheres, nrots, ok, n
	real, allocatable :: radii(:), ior_r(:), ior_i(:)
	real, allocatable :: pos(:,:), pos_rot(:,:)
	
	real :: dxt, dyt, a_eff_temp, conv 
	
	character(len=1000) :: junk
	
	contains

	subroutine read_spheres()
		implicit none
		real :: v = 0.0
		integer  :: i, allocatestatus

		open(unit=1,file=sphlist_fname)	! open sphere file.

		do i=1,5
			read(1,'(a)') junk		! ignore the header for now.
		end do 

		! this section will read the entire header in the future.
		nspheres = 1024

		! allocate necessary memory
		allocate(pos(nspheres,3),stat = allocatestatus)
  		if (allocatestatus /= 0) stop "*** not enough memory (pos) ***"
		allocate(pos_rot(nspheres,3),stat = allocatestatus)
  		if (allocatestatus /= 0) stop "*** not enough memory (pos_rot) ***"
		allocate(radii(nspheres),stat = allocatestatus)
  		if (allocatestatus /= 0) stop "*** not enough memory (radii) ***"
		allocate(ior_r(nspheres),stat = allocatestatus)
  		if (allocatestatus /= 0) stop "*** not enough memory (ior_r) ***"
		allocate(ior_i(nspheres),stat = allocatestatus)
  		if (allocatestatus /= 0) stop "*** not enough memory (ior_i) ***"

		! read in spheres
		do i=1,nspheres
			read(1, *) n, pos(i,1), pos(i,2), pos(i,3), radii(i) 
			ior_r(i) = ior_re
			ior_i(i) = ior_im
			radii(i) = radii(i)/2
			v = v+ (4.0*pi/3.0)*(radii(i))**3
		end do 

		close(1)

		! now normalize
		a_eff_temp = ((3*v)/(4*pi))**(1.0/3.0)
		conv = a_eff/a_eff_temp

		do i=1,nspheres
			pos(i,1) = pos(i,1)*conv
			pos(i,2) = pos(i,2)*conv 
			pos(i,3) = pos(i,3)*conv
			pos_rot(i,1) = pos(i,1)
			pos_rot(i,2) = pos(i,2)
			pos_rot(i,3) = pos(i,3)
			radii(i) = radii(i)*conv		
		end do
	end subroutine read_spheres

	function phi_spheres(x,y,k)
		implicit none
		real, dimension(ngrid), intent(in) :: x,y
		real, dimension(3) :: current_pos
		real, intent(in) :: k
		real :: r, l, m
		complex(c_double_complex), dimension(ngrid,ngrid) :: phi_spheres
		integer :: i, j, n ,xi, xf, yi,yf

		dxt = x(2) - x(1)
		dyt = y(2) - y(1)

		do i=1, nspheres
			! only modify the relevant section of the phi grid
			! indices: i = [xi,xj], j = [yi,yj]
			xi = int((pos_rot(i,1) - radii(i) - x(1))/dxt) + 1
			xf = int((pos_rot(i,1) + radii(i) - x(1))/dxt) + 1
			yi = int((pos_rot(i,2) - radii(i) - x(1))/dyt) + 1
			yf = int((pos_rot(i,2) + radii(i) - x(1))/dyt) + 1

			m = cmplx(ior_r(i), ior_i(i)) ! ior - 1
			
			do j=xi,xf
				do n=yi,yf
					current_pos = (/ x(j), y(n), 0.0 /)
					phi_spheres(j,n) = phi_spheres(j,n)+ k*m*chord_sphere(current_pos, pos_rot(i,:), radii(i))
				end do
			end do 
		end do 
		
	end function phi_spheres

	function shadow_spheres(x,y,k,rm)
		implicit none
		real, dimension(ngrid), intent(in) :: x,y 
		real, dimension(3,3), intent(in) :: rm
		real, intent(in) :: k 
		complex(c_double_complex), dimension(ngrid,ngrid) :: shadow_spheres, phi
		integer :: i, j


		! rotate sphere positions by the specified euler angles
		do i=1,nspheres
			pos_rot(i,:) = matmul(rm, pos(i,:))
		end do

		phi = phi_spheres(x,y,k) ! paint phi grid
		!$omp parallel shared(shadow_spheres,phi) 
		!$omp do schedule(dynamic) private(i,j)
		do j=1,ngrid
			do i=1,ngrid 
				! convert phi grid to shadow grid*(-1)^(i+j) so the fft is centered
				shadow_spheres(i,j) = (-1.0)**(i+j+1)*(1-exp( (0.0,1.0)*phi(i,j) ))
			end do
		end do 
		!$omp end do nowait
		!$omp end parallel
		
	end function shadow_spheres

end module spheres 