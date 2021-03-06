      PROGRAM hartree_fock
      IMPLICIT REAL*8 (a-h,o-z)
      DIMENSION alpha(2),E(2),tempK(2)
      DIMENSION S(2,2),H(2,2),P(2,2),F(2,2)
      DIMENSION tei(2,2,2,2)

      OPEN(10,file='HF.out',status='unknown')
      OPEN(20,file='zeta.dat',status='unknown')
c Read in the values of alpha1, alpha2, and k

      PRINT*,'Please enter the value for alpha1:'
      READ(*,*) alpha(1)
      PRINT*, ' alpha1 entered as ', alpha(1)

      PRINT*,'Please enter the value for alpha2:'
      READ(*,*) alpha(2)
      PRINT*,'alpha2 entered as ', alpha(2)

      PRINT*,'Please enter the initial value of k'
      READ(*,*) ratio
      PRINT*,'k entered as ', ratio

      PRINT*,'Enter unit displacement'
      READ(*,*)disp
      PRINT*,'displacement entered as ',disp

      PRINT*,'Enter number of unit displacements'
      READ(*,*)nstep


      DO istep=1,nstep

         C11=2
         C21=1
         ratio=C11/C21
         oldC11=0
         oldC21=0
         

         DO i=1,2
            DO j=1,2
               DO k=1,2
                  DO l=1,2
                     tei(i,j,k,l)=0
                  END DO
               END DO
               S(i,j)=0
               H(i,j)=0
               F(i,j)=0
               P(i,j)=0
            END DO
            tempK(i)=0
            E(i)=0
         END DO
         

c Calculate the overlap integral matrix S(i,j)
      DO i=1,2
         DO j=1,2
            S(i,j)=8.*((alpha(i)*alpha(j))**(3./2.))
     *           *((alpha(i)+alpha(j))**(-3.))
         END DO
      END DO

c Calculate the core-Hamiltonian matrix H(i,j)
      DO i=1,2
         DO j=1,2
            H(i,j)=4.*((alpha(i)*alpha(j))**(3./2.))
     *           *(-(alpha(j)**2.)*((alpha(i)+alpha(j))**(-3.))
     *           +alpha(j)*((alpha(i)+alpha(j)))**(-2.)
     *           -2.*((alpha(i)+alpha(j))**(-2.)))
         END DO
      END DO

c Calculate the two-electron integrals
      DO i=1,2
         DO j=1,2
            DO k=1,2
               DO l=1,2
                  alphasum=alpha(i)+alpha(j)+alpha(k)+alpha(l)
                  alphaprod=alpha(i)*alpha(j)*alpha(k)*alpha(l)
                  tei(i,j,k,l)=32*((alphaprod)**(3./2.))*
     *                 (-((alpha(k)+alpha(l))**(-2.))*
     *                 ((alphasum)**(-3.))-((alpha(k)+alpha(l))**(-3.))
     *                 *((alphasum)**(-2.))+((alpha(k)+alpha(l))**(-3.))
     *                 *((alpha(i)+alpha(j))**(-2.)))
               END DO
            END DO
         END DO
      END DO

c Loop over the following portions of the calc. until convergence
      itick=0
      DO WHILE (((C11-oldC11).GE.1E-4).AND.((C21-oldC21).GE.1E-4))    
         itick=itick+1
c Calculate the density matrix P(i,j)
      DO i=1,2
         DO j=1,2
            P(i,j)=2*((ratio**(4.-i-j))*((1+(ratio**2.)
     *           +2*ratio*S(1,2)))**(-1.))
         END DO
      END DO

c Calculate the Fock matrix elements F(i,j)
      Gmat=0
      DO i=1,2
         DO j=1,2
            DO k=1,2
               DO l=1,2
                 Gmat=Gmat+P(k,l)*(tei(i,j,l,k)-0.5*tei(i,k,l,j))
               END DO
            END DO
            F(i,j)=H(i,j)+Gmat
            Gmat=0
         END DO
      END DO

c Calculate the eigenvalues E
      a=1-S(2,1)**2.
      b=2*F(2,1)*S(2,1)-F(1,1)-F(2,2)
      c=F(1,1)*F(2,2)-(F(2,1)**2.)

      E(1)=(-b+sqrt((b**2.)-4*a*c))/(2*a)
      E(2)=(-b-sqrt((b**2.)-4*a*c))/(2*a)

      
c Calculate the new and improved value for k (ratio)
      DO i=1,2
         tempK(i)=(F(2,2)-F(2,1)-E(i)+S(2,1)*E(i))
     *        *((F(1,1)-F(2,1)-E(i)+S(2,1)*E(i))**(-1.))
      END DO
      
c Assign the maximum of the two new k values to ratio
      ratio=max(tempK(1),tempK(2))

c Calculate the Hartree Fock energy
      esum=0
      DO i=1,2
         DO j=1,2
            esum=esum+P(i,j)*(H(i,j)+F(i,j))
         END DO
      END DO
      HFE=0.5*esum
      

c Calc new and store old values of C11 and C21 to compare against
      oldC11=C11
      oldC21=C21

      C21=sqrt((ratio**2.)+1+2*ratio*S(1,2))
      C11=C21*ratio

      WRITE(10,*)itick,oldC11,oldC21,C11,C21,ratio,HFE
      END DO !DO WHILE loop


      WRITE(20,*)alpha(1),HFE
      
      alpha(1)=alpha(1)+disp
      END DO!alpha loop


      STOP
      END
