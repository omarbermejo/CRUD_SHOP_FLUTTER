# CRUD SHOP - Flutter

Aplicación desarrollada en **Flutter** con el objetivo de practicar y reforzar conocimientos previos mediante la implementación de un sistema tipo **Shop** con operaciones **CRUD** (Crear, Leer, Actualizar y Eliminar).

---

## Características

- CRUD de productos (Crear, listar, editar y eliminar)
- Estructura modular en Flutter (`lib/`)
- Uso de assets para imágenes, íconos o recursos
- Configuración mediante archivo `.env`
- Soporte para múltiples plataformas:
  - Android
  - iOS
  - Web
  - Windows
  - macOS
  - Linux

---

## Estructura del Proyecto

El repositorio incluye la estructura estándar de un proyecto Flutter:

```
CRUD_SHOP_FLUTTER/
│── lib/                 # Código fuente principal
│── assets/              # Recursos (imágenes, etc.)
│── android/             # Configuración Android
│── ios/                 # Configuración iOS
│── web/                 # Configuración Web
│── windows/             # Configuración Windows
│── macos/               # Configuración macOS
│── linux/               # Configuración Linux
│── .env                 # Variables de entorno
│── pubspec.yaml         # Dependencias y configuración Flutter
```

---

## Requisitos

Asegúrate de tener instalado:

- Flutter SDK
- Android Studio / VS Code
- Dart
- Emulador o dispositivo físico

---

## Instalación y Ejecución

### 1. Clonar el repositorio
```bash
git clone https://github.com/omarbermejo/CRUD_SHOP_FLUTTER.git
cd CRUD_SHOP_FLUTTER
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar `.env`
El proyecto incluye un archivo `.env`. Asegúrate de completarlo con las variables necesarias (por ejemplo: URLs de API, tokens o configuraciones).

Recomendación: Mantén este archivo fuera del repositorio en producción usando `.gitignore`.

### 4. Ejecutar el proyecto
```bash
flutter run
```

---

## Ejecutar pruebas (opcional)

```bash
flutter test
```

---

## Tecnologías usadas

- Flutter
- Dart
- Material Design

---

## Objetivo del proyecto

Este proyecto fue desarrollado como parte de un proceso de aprendizaje, para mejorar habilidades en Flutter y fortalecer el dominio de arquitectura, manejo de estado y operaciones CRUD.

---

## Capturas (opcional)

Agrega imágenes del proyecto para mejorar la presentación en GitHub:

```md
![Home](assets/screenshots/home.png)
![Form](assets/screenshots/form.png)
```

---

## Contribuciones

Las contribuciones son bienvenidas.

1. Haz un fork del proyecto
2. Crea tu rama: `git checkout -b feature/nueva-funcionalidad`
3. Haz commit: `git commit -m "Agrega nueva funcionalidad"`
4. Haz push: `git push origin feature/nueva-funcionalidad`
5. Abre un Pull Request

---

## Licencia

Este proyecto es de uso libre para fines educativos. Si deseas agregar una licencia formal, se recomienda la licencia MIT.
