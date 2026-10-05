# Features (Feature-First)

Cada feature segue Clean Architecture:

```
feature_name/
  domain/
    entities/
    repositories/     # interfaces
    usecases/
  data/
    datasources/
    models/
    repositories/     # *RepositoryImpl
  presentation/
    providers/        # ou bloc/
    pages/
    widgets/          # só widgets específicos da feature (não duplicar core)
```

Próximas features planejadas: `auth`, `movies`, `reviews`, `feed`, `awards`.
