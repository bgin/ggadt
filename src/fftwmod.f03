module fftw
    
    use, intrinsic :: iso_c_binding
       include '/opt/local/include/fftw3.f03'
    logical :: first_time = .true.
    type(c_ptr) :: plan
    integer ::  mode = fftw_estimate
    character(len=100) :: mode_name
    character(len=100) :: plan_filename

contains

    subroutine set_optimization_mode(mode_name_in)
        character(len=100), intent(in) :: mode_name_in

        mode_name = mode_name_in

        select case (mode_name)
        case('estimate')
            mode = fftw_estimate
        case('patient')
            mode = fftw_patient
        case('exhaustive')
            mode = fftw_exhaustive
        case('measure')
            mode = fftw_measure
        case default
            mode = fftw_estimate 
        end select
    end subroutine set_optimization_mode



    function fft(f,x,y)
        
        real, intent(in) :: x(:), y(:)
        complex(c_double_complex), intent(inout) :: f(:,:)
        complex(c_double_complex), dimension(size(x),size(y)) :: fft
        integer :: nx, ny
        integer :: error


        nx = size(x)
        ny = size(y)
        ! OMP threaderror = fftw_init_threads()
        ! OMP if (threaderror == 0) then
        ! OMP     write (0,*) "------------------------------"
        ! OMP     write (0,*) "Error initializing multiple threads. Program will attempt to proceed"
        ! OMP     write (0,*) "using 1 thread."
        ! OMP     write (0,*) "------------------------------"
        ! OMP     numthreads = 1
        ! OMP else
        ! OMP     numthreads = omp_get_max_threads()
        ! OMP endif
        ! OMP call fftw_plan_with_nthreads(numthreads)
        if (first_time) then
            error = fftw_import_wisdom_from_filename(trim(adjustl(plan_filename)))
            if (error == 0) then
                plan = fftw_plan_dft_2d(ny, nx, f ,fft, fftw_backward,mode)
                error = fftw_export_wisdom_to_filename(plan_filename)
            else
                plan = fftw_plan_dft_2d(ny, nx, f ,fft, fftw_backward,mode)
            end if
            first_time = .false.
        end if
        !write (0,*) "about to do fft"
        !plan = fftw_plan_dft_2d(ny, nx, f ,fft, fftw_backward,fftw_patient)
        call fftw_execute_dft(plan, f, fft)
    end function fft

    function fft_firstk(f,x,y,K)
        integer, intent(in) :: K
        integer, target :: kval
        integer :: ISIGN, lentwids
        type(c_ptr) ::  kptr,localplan 
        integer, dimension(1) :: kval_arr, null_vec
        integer, dimension(2) :: n_vec 
        real, intent(in) :: x(:), y(:)
        complex(c_double_complex), intent(inout) :: f(:,:)
        complex(c_double_complex), dimension(size(x),size(y)) :: working_fft
        complex(c_double_complex), dimension(K,K) :: fft_firstk
        complex(c_double_complex), allocatable :: twids(:,:)
        real :: TWOPI
        integer  :: N, NFFT, i,j,l,m 

        
        write (0, *) "Declared variables"
        do i=1,K
            do j=1,K
                fft_firstk(i,j) = 0.0
            end do 
        end do 
        write (0, *) "initialized fft_firstk"
        TWOPI = 8.*atan(1.)
        ISIGN = 1
        N = size(x)
        NFFT = N/K 
        lentwids = N - NFFT + 1
        kval = K**2
        kptr = c_loc(kval)
        kval_arr(1) = kval
        n_vec(1) = K
        n_vec(2) = K 
        write (0, *) "set variables"
        allocate(twids(lentwids, lentwids))

        write (0, *) "allocated twids."
        if (K*NFFT .ne. N) then
            write(0,*) "ERROR: NFFT = ",NFFT," and K = ",K,", but NFFT*K = ",NFFT*K," != ",N
            stop 
        endif
        write(0,*) "going to make plan..."


        localplan = fftw_plan_many_dft(2, n_vec , NFFT*NFFT, & 
                                    f, null_vec, NFFT,  &
                                    1, working_fft, null_vec, 1, K*K, &
                                    fftw_backward, fftw_estimate)
        write (0, *) "made plan"
        do i=0,(NFFT-1)
            do j=0,(K-1)
                do l=0,(NFFT-1)
                    do m=0,(K-1)
                        twids(i*(K-1) + j + 1, &
                              l*(K-1) + m + 1) &
                        = exp(CMPLX(0,1)*ISIGN*TWOPI*(i*j/size(x) + l*m/size(y)))
                    end do 
                end do 
            end do 
        end do
        write (0, *) "set twids."
        call fftw_execute_dft(localplan, f, working_fft)
        write (0, *) "executed plan"
        do i=0,(NFFT-1)
            do j=0,(K-1)
                do l=0,(NFFT-1)
                    do m=0,(K-1)
                        fft_firstk(j+1,m+1) = fft_firstk(j+1,m+1) + working_fft(j+i*K+1,m+l*K+1)*twids(j*(K-1)+i+1, l*(K-1)+m+1)
                    end do 
                end do 
            end do 
        end do
        write (0, *) "set fft_firstk"
        call fftw_destroy_plan(localplan)
        write (0, *) "destroyed plan "



    end function fft_firstk

    !function experimental_fft(f,x,y,K):
    !    
    !    real, intent(in) :: x(:), y(:)
    !    integer, intent(in) :: K 
    !    complex(c_double_complex), intent(inout) :: f(:,:)
    !    complex(c_double_complex), dimension(size(x),size(y)) :: new_grid(:,:)
    !    complex(c_double_complex), dimension(size(x),size(y)) :: fft
    !    integer :: nx, ny, i, j


    !    K = 
    !    ngrid_grain = 256
    !end function experimental_fft

end module fftw
