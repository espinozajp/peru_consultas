import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:html/parser.dart';

import 'package:cookie_jar/cookie_jar.dart';

class Sunat {
  final BASE = 'http://www.sunat.gob.pe/cl-ti-itmrconsruc';
  final RUC_CAPTCHA = 'http://www.sunat.gob.pe/cl-ti-itmrconsruc/captcha';
  final RUC_URL = 'http://www.sunat.gob.pe/cl-ti-itmrconsruc/jcrS00Alias';
  final RUC_URL_DETAIL =
      'http://www.sunat.gob.pe/cl-ti-itmrconsruc/jcrS00Alias';

  /// Obtiene la información básica de un contribuyente
  ///
  /// Se necesita el parámetro [rucQuery] el cual es el numero de RUC del contribuyente
  Future<String> rucBasico(String rucQuery) async {
    var httpclient = new HttpClient();
    var cj = new CookieJar();
    var rucResult = '';
    const body = "accion=random";

    await httpclient
        .postUrl(Uri.parse(RUC_CAPTCHA))
        .then((HttpClientRequest request) {
      request.headers.add('Content-Type', 'application/x-www-form-urlencoded');
      request.headers.add('Content-Length', body.length);
      //request.cookies.addAll(cj.loadForRequest(Uri.parse("http://www.sunat.gob.pe/")));
      request.write(body);
      return request.close();
    }).then((HttpClientResponse response) async {
      cj.saveFromResponse(
          Uri.parse("http://www.sunat.gob.pe/"), response.cookies);
      if (response.statusCode == 200) {
        String captcha = await response.transform(Utf8Decoder()).join();
        String rucBody = 'nroRuc=$rucQuery&accion=consPorRuc&numRnd=$captcha';
        await httpclient
            .postUrl(Uri.parse(RUC_URL))
            .then((HttpClientRequest request) {
          request.headers
              .add('Content-Type', 'application/x-www-form-urlencoded');
          request.headers.add('Content-Length', rucBody.length);
          request.cookies
              .addAll(cj.loadForRequest(Uri.parse("http://www.sunat.gob.pe/")));
          request.write(rucBody);

          return request.close();
        }).then((HttpClientResponse rucResponse) async {
          if (rucResponse.statusCode == 200) {
            rucResult = await rucResponse.transform(Latin1Decoder()).join();
            //print(rucResult);
          } else {}
        });
      } else {}
    });

    var document = parse(rucResult);
    //print(rucResult);
    int salto = 0;
    var table = document.querySelector('table');
    var trows = table.querySelectorAll('tr');

    var contribuyente = {}, repLegal = {};
    var fichaRuc = trows.first.children.last.text.split('-');

    contribuyente.addAll(
      {
        'ruc': fichaRuc[0].trim(),
        'razonSocial': fichaRuc[1].trim(),
        'tipo': trows[1].children.last.text.trim(),
      },
    );

    var persona = trows[2]
        .children
        .last
        .text
        .replaceAll('\n', '')
        .replaceAll('\t', '')
        .trim();

    if (contribuyente['tipo'].toString().contains('PERSONA') ||
        persona.contains('DNI')) {
      var infoPersona = persona.split('-');
      var infoDocIden = infoPersona[0].trim().split(' ');

      repLegal.addAll({
        'tipoDocumento': infoDocIden[0].trim(),
        'nroDocumento': infoDocIden[2].trim(),
        'nombreCompleto': infoPersona[1].trim(),
      });

      salto++;

      if (trows[6].children.length > 3) {
        repLegal.addAll({
          'ocupacion': trows[6].children[3].text.trim(),
        });
      } else {
        repLegal.addAll({
          'ocupacion': Null,
        });
      }
    }

    contribuyente.addAll({'repLegal': repLegal});
    contribuyente
        .addAll({'nombreComercial': trows[2 + salto].children[1].text.trim()});

    if (trows[2 + salto].children.length > 2) {
      contribuyente
          .addAll({'afectoNuevoRUS': trows[2 + salto].children[3].text.trim()});
    } else {
      contribuyente.addAll({'afectoNuevoRUS': ''});
    }

    contribuyente
        .addAll({'fechaInscripcion': trows[3 + salto].children[1].text.trim()});
    if (trows[3 + salto].children.length > 2) {
      contribuyente.addAll(
          {'fechaInicioActividades': trows[3 + salto].children[3].text.trim()});
    } else {
      contribuyente.addAll({'fechaInicioActividades': ''});
    }

    contribuyente.addAll({'estado': trows[4 + salto].children[1].text.trim()});
    if (trows[4 + salto].children.length > 3) {
      contribuyente
          .addAll({'fechaBaja': trows[4 + salto].children[3].text.trim()});
    } else {
      contribuyente.addAll({'fechaBaja': ''});
    }

    contribuyente
        .addAll({'condicion': trows[5 + salto].children[1].text.trim()});
    contribuyente.addAll({
      'direccionFiscal': trows[6 + salto]
          .children[1]
          .text
          .replaceAll('\n', '')
          .replaceAll('\t', '')
          .replaceAll('  ', '')
          .trim()
    });

    contribuyente.addAll({
      'sistemaEmisionComprobante': trows[7 + salto].children[1].text.trim()
    });
    if (trows[7 + salto].children.length > 3) {
      contribuyente.addAll({
        'actividadComercioExterior': trows[7 + salto].children[3].text.trim()
      });
    } else {
      contribuyente.addAll({'actividadComercioExterior': ''});
    }

    contribuyente.addAll(
        {'sistemaContabilidad': trows[8 + salto].children[1].text.trim()});

    return json.encode(contribuyente);
  }
}
