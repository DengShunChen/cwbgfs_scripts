SHELL=/bin/ksh

machine=fx100

#SRCS=	gm2gm_main.f gm2gm_sub.f prexp_hybrid_cwb.f cwb.f
SRCS=	gm2gm_main.f90 gm2gm_sub.f90 prexp_hybrid_cwb.f90 cwb.f90
OBJS=	$(SRCS:.f90=.o)

#FC =    /users/xa09/dms_compile/$(machine)/dmsompf77
FC =    /users/xa09/dms_compile/$(machine)/dmsompf90

CMD =	../gm2gm_Noahq_$(machine).exe

INCLUDE = .
LDFLAGS =
LIBS =

FFLAGS =  -Kauto -Kautoobjstack -fw -Fwide -Kocl

.SUFFIXES : .F90 .f90 .o .f

all:		$(CMD)

$(CMD):		$(OBJS)
	@echo
	@echo '---> Linking  $<'
	$(FC) $(LDFLAGS) -o $(@) $(OBJS) $(LIBS)

.f90.o:
	@echo
	@echo '---> Compiling $<'
	$(FC) $(LDFLAGS) -c $<

.f.o:


clean:
	-rm -f $(OBJS) *.lst 

