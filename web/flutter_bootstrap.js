{{flutter_js}}
{{flutter_build_config}}

// O Flutter não muda o nome do main.dart.js entre versões. A versão do build na
// URL faz o navegador baixar o código novo em vez de reaproveitar um cache antigo.
const tuliBuildVersion = {{flutter_service_worker_version}};
if (tuliBuildVersion) {
  for (const build of _flutter.buildConfig.builds) {
    if (build.compileTarget === 'dart2js') {
      build.mainJsPath = (build.mainJsPath || 'main.dart.js') + '?v=' + tuliBuildVersion;
    }
  }
}

_flutter.loader.load();
