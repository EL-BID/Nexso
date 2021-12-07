*Esta herramienta digital está publicada en página web de la iniciativa [Código para el Desarrollo](http://code.iadb.org/es/repositorio/19/nexso)*
## NEXSO
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=EL-BID_Nexso&metric=alert_status)](https://sonarcloud.io/dashboard?id=EL-BID_Nexso)
![analytics image (flat)](https://raw.githubusercontent.com/vitr/google-analytics-beacon/master/static/badge-flat.gif)
![analytics](https://www.google-analytics.com/collect?v=1&cid=555&t=pageview&ec=repo&ea=open&dp=/Nexso/readme&dt=&tid=UA-4677001-16)
### Descripción
---
Plataforma de innovación abierta para organizaciones. Con esta herramienta digital puedes gestionar todos los retos de innovación abierta desde un mismo portal. Puedes gestionar los registros, las normas, el jurado, los tiempos. Los participantes pueden publicitar sus proyectos, buscar financiación y conectarse entre ellos. Nexso permite gestionar todas las fases de un reto de innovación abierta desde una sola plataforma.

### Arquitectura de aplicación
---
NEXSO es una aplicación ASP.NET del tipo Web Form construida sobre Dot Net Nuke / Evoq (DNN) 7 Community Edition bajo una arquitectura de aplicación de cinco capas.

Descripción de las capas


Cliente: un conjunto de estilos y piezas de Javascript para proporcionar una experiencia de usuario amigable.
- /VS2013_PROJECT/NZPortalWeb/Portals/0/Skins/NexsoV2  Tema utilizado en el 80% de la aplicación
- /VS2013_PROJECT/NZPortalWeb/Portals/0/Skins/NexsoVZ  Tema utilizado en el 20% de la aplicación


Presentación: un conjunto de módulos Dot Net Nuke que exponen todas las funcionalidades.
/VS2013_PROJECT/NZPortalWeb/DesktopModules/Nexso

Business: es una biblioteca que contiene un conjunto de objetos que proporcionan un catálogo de funcionalidades para que la capa de presentación y servicio interactúen con otros objetos dentro de la aplicación.

- /VS2013_PROJECT/NexsoProBLL 


Datos: es una librería que contiene un conjunto de objetos para almacenar y recupera los datos de la aplicación.
- /VS2013_PROJECT/NexsoProBLL
- /VS2013_PROJECT/NEXSO_DB contiene el esquema de la aplicación NEXSO
- /VS2013_PROJECT/DNN_DB esto contiene el esquema para el CMS, Dot Net Nuke

Servicios Adicionales: es un conjunto de objetos auxiliares para consumir servicios adicionales.
- /VS2013_PROJECT/MIFWebServices esta es una interfaz para consumir los Servicios Web del Fondo Multilateral de Inversiones
- /VS2013_PROJECT/NexsoServices es una biblioteca que expone una API REST, utilizando .NET Web Api y DNN para interactuar con la aplicación.


### Vamos más allá, hacer que sea de código abierto social
---
El software es una herramienta fundamental para el diseño e implementación de proyectos y programas. Esta herramienta se abre bajo el programa de [Código para el Desarrollo](code.iadb.org) del BID, que busca consolidar su compromiso con el uso y promoción del conocimiento abierto, así como acelerar el diálogo sobre cómo la tecnología puede impulsar el desarrollo de América Latina y el Caribe.

### Requisitos de desarrollo
---

- .NET 4.5
- Visual Studio 2013 o superior

### Cómo instalar
---

1. Abre la solución NZPortalWeb.sln con Visual Studio 2013 o superior
2. Regenera la base de datos en SQL Server 2012
3. Configura el Web.config con tu propia configuración
4. Ejecuta y depura la aplicación con Visual Studio

Voila!! Estás listo.

Importante:

> El proyecto actual tiene fines demostrativos. Es posible que no se ejecute correctamente porque no se proporciona el script de base de datos y algunas licencias se requieren para correr algunas funcionalidades.

Licencia:

> Para ejecutar el blog, el usuario debe obtener una licencia para Easy DNN News. Las Dll se han removido de la aplicación.

### Desarrollo
---
Durante el desarrollo, debe utilizar Visual Studio y SQL Server 2012.

### Cómo contribuir
---

1. Actualizar la aplicación a .NET Core
2. Implementar el Proyecto de BD (contacta al dueño del repositorio)
3. Sustituir los componentes de componentes de código abierto
4. Retirar los componentes que ya no son necesarios
5. Actualizar la Web.Api
6. Implementar MVC en algunos módulos
7. Mejorar estilos
8. Implementar HTML5

### Más información
---
## Análisis de calidad

De acuerdo al sistema de evaluación de software definido en la guía de ciclo de vida de desarrollo de software, el análisis de esta herramienta ha generado la siguiente evaluación

* Blocker issues: 0 (> 0) **Low** 
* Duplicated lines: 15.8% (< 25%) **Standard**
* Critical issues: 6 (< 10) **Standard**
* Public documented API: 42.3% (< 50%) **Standard**
* Technical debt: 63d (> 60d) **Low**
* Test coverage: 0% (< 10%) **Low**

Más información en [este link.](https://el-bid.github.io/software-life-cycle-guide/delivery/evaluation-matrix/)

## Licencias de terceros

Para los siguientes componentes de terceros lea cuidadosamente antes de descargar y ejecute el código correctamente.

Licencias de propietarios

- EASY DNN News es necesario obtener una copia válida y licencia para la suite http://www.easydnnsolutions.com/ , debe instalarse en la carpeta / bin

- Los controles de TELERIK Rad Controls son necesarios en la aplicación. DNN ya no soporta los componentes originales de Telerik, http://www.dnnsoftware.com/community-blog/cid/154991/dnn-and-telerik-rad-controls. Además, se debe obtener una copia y licencia válidas para Telerik Rad Control http://www.telerik.com/products/aspnet-ajax.aspx.

- AYLIEN es requerido para indexar internamente los contenidos. Se requiere una cuenta para ejecutar esta funcionalidad. Http://aylien.com/text-api

Licencia MIT

- GhostScript Sharp https://github.com/mephraim/ghostscriptsharp
- Argotic https://argent.codeplex.com/
- SharpZipLib https://github.com/icsharpcode/SharpZipLib
- Tweetsharp https://github.com/shugonta/tweetsharp
- NewtonSoft Json https://github.com/JamesNK/Newtonsoft.Json

Apache

- Luecene https://lucenenet.apache.org/
- Webactivator https://github.com/davidebbo/WebActivator
- ImageProcessor https://github.com/JimBobSquarePants/ImageProcessor


## Licencia

[Licencia MIT](https://github.com/EL-BID/Nexso/blob/master/LICENSE)

## Autores
---
BID

- Jairo Anaya
- Stephen Chapman

Studio Yellow
- Marina Yofre
- Valeria Ruiz

Flipside
- Olaf Verman
- Daniel Silva
- Ricardo Saavedra

Sinapsis Innovación

- Felipe Villegas
- Juliana Manrique
- Gonzalo Isaza

## Otros enlaces

Http://server.arcgis.com/en/

Http://www.nexso.org/

https://www.fomin.org/
