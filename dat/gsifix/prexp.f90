      subroutine prexp(lev,ptop,sigma,pt,pk,pk2,plt,nvcoor)
!
!  subroutine to compute p to the kapa on odd and even levels
!
! *** input ****
!
!  lev: number of vertical levels
!  sig: sigma levels
!  pt: terrain pressure
!
! *** output ***
!
!  pk: odd (full) level p**capa
!  pk2: even( half) level p**capa
!
! **************************************************
!
!
      integer :: lev, kbot, k, nvcoor
      real ::  pk2(lev+1),pk(lev),sigma(lev+1,nvcoor), plt(lev)
      real :: pl2(2)

      real :: capa, capap1, opok
!
!  compute  pressure variables
!
      capa  = 1.0/3.5
      capap1= 1.0+capa
      opok  = 1.0/1000.0**capa
!
      kbot= 1
      k= 1
      ptopk= ptop*opok*ptop**capa

      if (nvcoor == 1 ) then 
        pl2(kbot)= sigma(2,1)*pt+ptop
      elseif(nvcoor == 2 ) then
        pl2(kbot)= sigma(2,1)*pt+sigma(2,2)+ptop
      endif

      pk2(k)   = opok*pl2(kbot)**capa
      pk(k)    = (pl2(kbot)*pk2(k)-ptopk)    &
                / (capap1*(pl2(kbot)-ptop))
      plt(k)   = 1000.0*pk(k)*pk(k)*pk(k)*sqrt(pk(k))
!
      do k = 2, lev
        ktop= kbot
        kbot= 3 - ktop

        if (nvcoor == 1 ) then 
          pl2(kbot)= sigma(k+1,1)*pt+ptop
        elseif(nvcoor == 2 ) then
          pl2(kbot)= sigma(k+1,1)*pt+sigma(k+1,2)+ptop
        endif

        pk2(k)   = opok*pl2(kbot)**capa
        pk(k)    = (pl2(kbot)*pk2(k)-pl2(ktop)*pk2(k-1))  &
                  / (capap1*(pl2(kbot)-pl2(ktop)))
        plt(k)   = 1000.0*pk(k)*pk(k)*pk(k)*sqrt(pk(k))
      enddo
!
      return
      end
