import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { json, urlencoded } from 'body-parser';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common/pipes/validation.pipe';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';


async function bootstrap() {
  const app = await NestFactory.create< NestExpressApplication>(AppModule);
  // Increase body parser limits for multipart image uploads (avoids
  // "request entity too large" on PATCH /api/users/me, etc.)
  app.use(json({ limit: '15mb' }));
  app.use(urlencoded({ limit: '15mb', extended: true }));

    // Serve uploaded files (e.g. profile images) statically
  (app as any).useStaticAssets('uploads', { prefix: '/uploads/' });

  app.setGlobalPrefix('api');
  app.useGlobalFilters(new AllExceptionsFilter());
  app.enableCors({
    origin: true,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      // Coerce JSON string numbers ("123") into number fields so the
      // frontend's `int.tryParse(...) ?? 0` payloads are accepted.
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  // Parse environment PORT explicitly or fall back to 10000/3001
  const port = process.env.PORT ? parseInt(process.env.PORT, 10) : 10000;

  await app.listen(port, '0.0.0.0');
  console.log(`Application is running on port ${port}`);
}
bootstrap();