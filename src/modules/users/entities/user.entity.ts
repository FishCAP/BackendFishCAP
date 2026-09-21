import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { NotificationEntity } from '../../notifications/entities/notification.entity/notification.entity';
import { PondEntity } from '../../ponds/entities/pond.entity/pond.entity';

@Entity('users')
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'full_name', type: 'varchar', length: 100, nullable: false })
  fullName!: string;

  @Column({ name: 'email', type: 'varchar', length: 100, unique: true, nullable: false })
  email!: string;

  @Column({ name: 'password_hash', type: 'varchar', length: 255, nullable: true, select: false })
  passwordHash!: string | null;

    @Column({ name: 'phone', type: 'varchar', length: 20, nullable: true })
  phone?: string;

  @Column({ name: 'profile_image', type: 'varchar', length: 500, nullable: true })
  profileImage?: string | null;

  /** Cloudinary public_id of the current profile image (for replacement). */
  @Column({ name: 'profile_image_public_id', type: 'varchar', length: 255, nullable: true })
  profileImagePublicId?: string | null;

  @Column({ name: 'created_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt!: Date;

  @OneToMany(() => PondEntity, (pond) => pond.owner)
  ponds!: PondEntity[];

  @OneToMany(() => NotificationEntity, (notification) => notification.user)
  notifications!: NotificationEntity[];

  @Column({ type: 'varchar', nullable: true })
  resetTokenHash?: string | null;

  @Column({ type: 'timestamptz', nullable: true })
  resetTokenExpiresAt?: Date | null;
  password: any;
}
