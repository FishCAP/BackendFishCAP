import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Response } from 'express';

/**
 * Global exception filter.
 *
 * - HttpExceptions keep their original status/message (e.g. 400 validation,
 *   401, 404, 409).
 * - Unexpected errors are logged with a full stack trace (so 500s become
 *   debuggable from the server console) and a safe JSON body is returned to
 *   the client instead of an empty HTML "Internal Server Error" page.
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest();

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const res = exception.getResponse();
      const message =
        typeof res === 'string'
          ? res
          : (res as { message?: string | string[] }).message ?? exception.message;

      response.status(status).json({
        statusCode: status,
        message,
        error: exception.name,
        path: request.url,
      });
      return;
    }

    // Unknown error → log full stack server-side, return generic 500 JSON.
    const status = HttpStatus.INTERNAL_SERVER_ERROR;
    const message = exception instanceof Error ? exception.message : 'Internal server error';

    this.logger.error(
      `Unhandled exception on ${request.method} ${request.url}: ${message}`,
      exception instanceof Error ? exception.stack : undefined,
    );

    response.status(status).json({
      statusCode: status,
      message: 'Internal server error',
      path: request.url,
    });
  }
}