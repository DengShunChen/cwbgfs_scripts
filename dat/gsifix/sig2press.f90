program sig2press
  implicit none
  integer :: k, nsig
  real, allocatable :: sigma(:,:)
  real, parameter :: ptop=0.1
  real, parameter :: ps=1000.0
  real, allocatable, dimension(:) :: pk2
  real, allocatable, dimension(:) :: plt, pk

 
  open(22,file='global_siglevel.cwbl60.txt',form='formatted')

  read(22,*) nsig
 
  allocate(sigma(nsig+1,2))
  allocate(plt(nsig))
  allocate(pk(nsig))
  allocate(pk2(nsig+1))
  
  
  sigma(1,1)=1.
  sigma(nsig+1,1)=0.
  read(22,*) (sigma(k,1),k=2,nsig)
  write(6,*) nsig
  
  sigma(1:nsig+1,2) = sigma(nsig+1:1:-1,1)
  write(6,*) (sigma(k,1),k=1,nsig+1)

  call prexp(nsig,ptop,sigma(:,2),(ps-ptop),pk,pk2,plt,1) 

  write(6,'(a4,2x,a6,2x,a10)') 'levs','press','sigma'
  do k=1,nsig
    write(6,'(i4,2x,f6.2,2x,e10.5)') k,plt(k),sigma(k,2)
  enddo

  deallocate(sigma)

end program sig2press
