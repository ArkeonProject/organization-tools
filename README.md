# 🏛 ArkeonProject — Organization Tools

Repositorio oficial de herramientas internas para estandarizar:

- ⚡ Protección de ramas (main / develop)
- ⚙️ Políticas GitFlow profesionales
- 🧰 Scripts automáticos para toda la organización
- 🔄 Creación automática de ramas
- 🔐 Cumplimiento de reglas CI/CD

---

## 📌 Contenido

### `organization-branch-protection.sh`
Script que:
- Crea `develop` si no existe
- Aplica reglas estrictas a `main`
- Aplica reglas flexibles y correctas a `develop`
- Valida la configuración
- Funciona en todos los repos de la organización automáticamente

Ideal para garantizar un estándar profesional sin GitHub Team.

---

## 🚀 Uso rápido

```bash
chmod +x organization-branch-protection.sh
./organization-branch-protection.sh
```

---

## 🌐 Requisitos

- GitHub CLI (`gh`)
- Acceso administrador en la organización
- Autenticación previa con:

```bash
gh auth login
```

---

## 🧠 Nota profesional

Este repositorio centraliza todas las políticas de desarrollo de ArkeonProject:

- GitFlow real
- Linear history
- Ramas protegidas
- CI/CD estándar
- Automatizaciones internas

