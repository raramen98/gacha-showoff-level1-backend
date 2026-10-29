import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { Pool, QueryResultRow } from 'pg';
import { createPool } from './pool';

@Injectable()
export class DbService implements OnModuleInit, OnModuleDestroy {
  private readonly pool: Pool = createPool();

  /** 서버가 켜질 때 미리 연결해 둬서, 첫 요청이 느리거나 실패하지 않게 한다 (기다리지는 않음) */
  onModuleInit() {
    this.pool
      .query('SELECT 1')
      .then(() => console.log('🔌 DB에 미리 연결해 뒀어요.'))
      .catch((error) => console.warn('⚠️ DB에 미리 연결하지 못했어요:', error.message));
  }

  async query<T extends QueryResultRow = any>(text: string, params: unknown[] = []): Promise<T[]> {
    const result = await this.pool.query<T>(text, params);
    return result.rows;
  }

  async onModuleDestroy() {
    await this.pool.end();
  }
}
