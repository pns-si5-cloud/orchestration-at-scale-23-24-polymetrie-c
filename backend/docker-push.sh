#!/bin/bash

# Ce script automatise la construction, le tag et le push d'une image Docker.

# Vérifiez si le bon nombre de paramètres est passé
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <nom-image> <tag-image> <version>"
    exit 1
fi

# Assignez les paramètres à des variables pour une meilleure lisibilité
NOM_IMAGE=$1
TAG_IMAGE=$2
VERSION=$3

# Construire l'image Docker
echo "Construction de l'image Docker $NOM_IMAGE..."
docker build -t $NOM_IMAGE .

# Tag l'image Docker
echo "Tag de l'image Docker $NOM_IMAGE avec $TAG_IMAGE:$VERSION..."
docker tag $NOM_IMAGE $TAG_IMAGE:$VERSION

# Push l'image Docker
echo "Push de l'image Docker $TAG_IMAGE:$VERSION..."
docker push $TAG_IMAGE:$VERSION

echo "Opérations terminées avec succès."
