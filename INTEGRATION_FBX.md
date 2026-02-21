# 🌿 Intégration du modèle 3D Plante

## Fichier copié
- **Source** : `D:\Users\Brice\Downloads\tripo_convert_53bb83a4-5e49-4759-93fc-10f35ff6a0d9.fbx`
- **Destination** : `C:\Users\Brice\Desktop\Github\roblox-game\PlantMonster.fbx`

## 📥 ÉTAPES POUR IMPORTER DANS ROBLOX STUDIO

### 1. Ouvrir Roblox Studio
- Lance ton projet avec Rojo connecté
- Dans la barre du haut : **View** → **Asset Manager**

### 2. Importer le FBX
- Dans Asset Manager, clique **Import 3D**
- Sélectionne `PlantMonster.fbx`
- Roblox va convertir le FBX en MeshPart

### 3. Configurer le modèle
Une fois importé :
- Glisse le mesh dans **Workspace**
- Renomme-le `PlantMonster`
- Ajoute-lui les composants nécessaires :
  ```
  PlantMonster (Model)
  ├─ HumanoidRootPart (Part) - point d'ancrage
  ├─ PlantMesh (MeshPart) - le visuel du FBX
  ├─ Humanoid (pour animations/santé)
  └─ BodyColors (optionnel)
  ```

### 4. Adapter le code
Dans `MonsterDatabase.lua`, ajoute ce monstre Plante :

```lua
{
    id = "plantbeast",
    name = "Plant Beast",
    element = "Plante",
    rarity = "Rare",
    baseStats = {
        HP = 180,
        ATK = 65,
        DEF = 75,
        SPD = 40
    },
    skills = {"liane", "racines", "photosynthese"},
    evolution = nil,
    modelName = "PlantMonster", -- Correspond au nom dans Workspace
    description = "Une créature végétale redoutable"
}
```

### 5. Publier le modèle
Pour que Rojo puisse l'utiliser :
- Clique droit sur `PlantMonster` → **Save to Roblox**
- Ou exporte-le comme **Model file** (.rbxm)
- Place-le dans `src/ReplicatedStorage/Models/`

### 6. Référencer dans le spawn
Le système de spawn cherchera automatiquement le modèle par son nom dans `ReplicatedStorage.Models`.

## 🎨 TEXTURE / COULEUR

Si le modèle est gris :
- Sélectionne le MeshPart
- Dans Properties → **TextureID** : ajoute une texture
- Ou change **Color** et **Material** (Grass, Leafy, etc.)

## ✅ ROJO CORRIGÉ

Le problème de fermeture était dû aux fichiers `.server.lua` à la racine.
**Solution** : Scripts déplacés dans `ServerScriptService/Main/`

Rojo tourne maintenant sur **http://localhost:34872**
