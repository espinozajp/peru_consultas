import 'package:test/test.dart';

import 'package:peru_consultas/peru_consultas.dart';

void main() {
  test('adds one to input values', () {
    final sunat = Sunat();
    expect(sunat.rucBasico('10706013437'),
        '{"ruc":"10706013437","razonSocial":"ESPINOZA ALEJABO JOHAN PIERRE","tipo":"PERSONA NATURAL SIN NEGOCIO","repLegal":{"tipoDocumento":"DNI","nroDocumento":"70601343","nombreCompleto":"ESPINOZA ALEJABO, JOHAN PIERRE","ocupacion":"99 - PROFESION U OCUPACION NO ESPECIFICADA"},"nombreComercial":"-","afectoNuevoRUS":"","fechaInscripcion":"15/12/2011","fechaInicioActividades":"15/12/2011","estado":"ACTIVO","fechaBaja":"","condicion":"HABIDO","direccionFiscal":"-","sistemaEmisionComprobante":"MANUAL","actividadComercioExterior":"SIN ACTIVIDAD","sistemaContabilidad":"MANUAL"}');
//    expect(calculator.addOne(-7), -6);
//    expect(calculator.addOne(0), 1);
//    expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });
}
