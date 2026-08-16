# ExcelUploaderRAPUnmanaged
Excel upload using static action

A simple **SAP RAP Unmanaged** application demonstrating two practical RAP action patterns using a custom **Z table**.

<img width="1137" height="632" alt="image" src="https://github.com/user-attachments/assets/d37d6c9a-7f10-44a8-9619-3aa0df847146" />

## What it demonstrates

* **Static action** to open a dialog, accept remarks and an Excel file, and process the uploaded data.
* **Instance action** to select a record, provide parameters, and execute custom business logic.
* **Unmanaged RAP** for scenarios where custom persistence and processing are required.
* **Fiori elements** UI with action parameter dialogs.

## Use Case

The example manages batch shelf-life data.

**Extend Expiry Mass**
A static action allows the user to upload an Excel file containing multiple batches and process them in one operation.

**Extend Expiry**
An instance action allows the user to select a batch, provide parameters such as extension days and remarks, and process that specific record.

## Why this example?

This project provides a simple reference for implementing:

* Excel/media handling through a RAP action
* Mass processing without creating a dedicated upload entity
* Parameterized instance actions
* Custom business logic with unmanaged RAP

## Architecture

```text
Fiori Elements
      |
      v
   RAP Actions
   /         \
Static       Instance
Action       Action
  |             |
Excel        Parameters
  |             |
  +-------> Z Table
```

The goal is to demonstrate an easy and reusable approach for handling **media uploads with static actions** and **custom processing with parameterized instance actions** in RAP.
