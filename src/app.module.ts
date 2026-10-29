import { Module } from '@nestjs/common';
import { DbModule } from './db/db.module';
import { HealthModule } from './health/health.module';
import { PostsModule } from './posts/posts.module';
import { SeriesModule } from './series/series.module';

@Module({
  imports: [DbModule, HealthModule, SeriesModule, PostsModule],
})
export class AppModule {}
