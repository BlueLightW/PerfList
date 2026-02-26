String generateDocumentId(String title) {
          // Remove caracteres inválidos e substitui espaços por underscores
          final documentId = title
              .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
              .replaceAll(' ', '_')
              .toLowerCase();

            return documentId.isEmpty ? 'default_id' : documentId;
          }