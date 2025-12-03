/*==============================================================*/
/* DBMS name:      PostgreSQL 9.x                               */
/* Created on:     2025/4/2 20:59:38                            */
/*==============================================================*/


drop table Landlord;

drop table contract;

drop table house;

drop table tenant;

/*==============================================================*/
/* Table: Landlord                                              */
/*==============================================================*/
create table Landlord (
   landlord_ID          SERIAL not null,
   landlord_name        VARCHAR(100)         null,
   landlord_contract    CHAR(11)             null,
   "landlords'house"    VARCHAR(999)         null,
   Column_5             CHAR(10)             null,
   constraint PK_LANDLORD primary key (landlord_ID)
);

/*==============================================================*/
/* Table: contract                                              */
/*==============================================================*/
create table contract (
   contract_ID          SERIAL not null,
   house_ID             SERIAL not null,
   tenant_ID            SERIAL not null,
   rent_cost            DECIMAL(100,2)       null,
   duration             INT4                 null,
   start_date           DATE                 null,
   end_date             DATE                 null,
   constraint PK_CONTRACT primary key (contract_ID)
);

/*==============================================================*/
/* Table: house                                                 */
/*==============================================================*/
create table house (
   house_ID             SERIAL not null,
   landlord_ID          SERIAL not null,
   address              VARCHAR(999)         null,
   area                 DECIMAL(100,2)       null,
   constraint PK_HOUSE primary key (house_ID)
);

/*==============================================================*/
/* Table: tenant                                                */
/*==============================================================*/
create table tenant (
   tenant_ID            SERIAL not null,
   tenant_name          VARCHAR(100)         null,
   tenant_contact       CHAR(11)             null,
   constraint PK_TENANT primary key (tenant_ID)
);

alter table contract
   add constraint FK_CONTRACT_HAS_HOUSE foreign key (house_ID)
      references house (house_ID)
      on delete restrict on update restrict;

alter table contract
   add constraint FK_CONTRACT_SIGNS_TENANT foreign key (tenant_ID)
      references tenant (tenant_ID)
      on delete restrict on update restrict;

alter table house
   add constraint FK_HOUSE_OWNS_LANDLORD foreign key (landlord_ID)
      references Landlord (landlord_ID)
      on delete restrict on update restrict;

