%module box

%pythonprepend BoxMatrix::BoxMatrix(const EcmTransform &, WZetaRGLCalculator &, uint, const std::string&, uint) %{
  self.incm = incm
  self.wzetacalc = wzetacalc
%}

%{
#include "cmframe.h"
#include "zeta.h"
#include "box_matrix.h"
%}

%include "std_string.i"
%include "std_complex.i"
%include "std_vector.i"
%include "std_list.i"
namespace std {
  %template(vectori) vector<int>;
  %template(vectord) vector<double>;
  %template(vectorc) vector<std::complex<double> >;
  %template(listd)   list<double>;
};

#include "typemaps.i"
%apply std::vector<cmplx> *OUTPUT { std::vector<cmplx>& results };

%feature("autodoc","1");

%include "exception.i"
%exception {
  try {
    $action
  } catch (const std::runtime_error &e) {
    SWIG_exception(SWIG_RuntimeError, e.what());
  } catch (const std::invalid_argument &e) {
    SWIG_exception(SWIG_ValueError, e.what());
  }
}

%include "cmframe.h"
%include "zeta.h"
%include "box_matrix.h"

%extend EcmTransform {
  char *__repr__() {
    static char tmp[1024];

    std::vector<int> d = $self->getdvec();
    double L = $self->getMrefL();
    bool equalmasses = $self->areEqualMasses();
    double m1 = $self->getMass1OverMref();
    double m2 = $self->getMass2OverMref();

    if (equalmasses)
      snprintf(tmp, 1024, "EcmTransform( %d,%d,%d, %g, %g )", d[0],d[1],d[2], L, m1);
    else
      snprintf(tmp, 1024, "EcmTransform( %d,%d,%d, %g, %g,%g )", d[0],d[1],d[2], L, m1, m2);
    return tmp;
  }
}

%extend BoxMatrixQuantumNumbers {
  char *__repr__() {
    static char tmp[1024];

    uint rJ2 = $self->getRowJtimestwo();
    uint rL  = $self->getRowL();
    uint rnc = $self->getRowNocc();
    uint cJ2 = $self->getColumnJtimestwo();
    uint cL  = $self->getColumnL();
    uint cnc = $self->getColumnNocc();

    snprintf(tmp, 1024, "BoxMatrixQuantumNumbers( %d,%d,%d, %d,%d,%d )", rJ2,rL,rnc, cJ2,cL,cnc);
    return tmp;
  }
  char *__str__() {
    static char tmp[1024], rJ[32], cJ[32];

    uint rJ2 = $self->getRowJtimestwo();
    uint rL  = $self->getRowL();
    uint rnc = $self->getRowNocc();
    uint cJ2 = $self->getColumnJtimestwo();
    uint cL  = $self->getColumnL();
    uint cnc = $self->getColumnNocc();

    if (rJ2 % 2 == 0)
      snprintf(rJ, 32, "%d", rJ2/2);
    else
      snprintf(rJ, 32, "%d/2", rJ2);
    if (cJ2 % 2 == 0)
      snprintf(cJ, 32, "%d", cJ2/2);
    else
      snprintf(cJ, 32, "%d/2", cJ2);

    snprintf(tmp, 1024, "row( J=%s, L=%d, n=%d ), column( J=%s, L=%d, n=%d )", rJ,rL,rnc, cJ,cL,cnc);
    return tmp;
  }
}

%extend BoxMatrix {
  int __len__() {
    return $self->getNumberOfIndepElements();
  }
  char *__repr__() {
    static char tmp[1024];

    const EcmTransform &ecm = $self->getEcmTransform();
    uint S2 = $self->getTotalSpinTimesTwo();
    const std::string &lg = $self->getLittleGroupIrrep();
    uint Lmax = $self->getLmax();

    snprintf(tmp, 1024, "BoxMatrix( %s, WZetaRGLCalculator(), %d, '%s', %d )", EcmTransform___repr__(const_cast<EcmTransform *>(&ecm)), S2, lg.c_str(), Lmax );
    return tmp;
  }
  char *__str__() {
    static char tmp[1024], mstr[128], S[32];

    const EcmTransform &ecm = $self->getEcmTransform();
    uint S2 = $self->getTotalSpinTimesTwo();
    const std::string &lg = $self->getLittleGroupIrrep();
    uint Lmax = $self->getLmax();

    std::vector<int> d = ecm.getdvec();
    double L = ecm.getMrefL();
    bool equalmasses = ecm.areEqualMasses();
    double m1 = ecm.getMass1OverMref();
    double m2 = ecm.getMass2OverMref();

    if (equalmasses)
      snprintf(mstr, 128, "%g", m1);
    else
      snprintf(mstr, 128, "(%g,%g)", m1,m2);
    if (S2 % 2 == 0)
      snprintf(S, 32, "%d", S2/2);
    else
      snprintf(S, 32, "%d/2", S2);
    snprintf(tmp, 1024, "BoxMatrix( d=(%d,%d,%d), %s, S=%s, Lmax=%d, m=%s, L=%g )", d[0],d[1],d[2], lg.c_str(), S, Lmax, mstr, L);
    return tmp;
  }
}
