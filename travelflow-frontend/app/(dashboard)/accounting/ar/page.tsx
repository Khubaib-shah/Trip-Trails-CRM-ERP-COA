"use client";

import { useEffect, useState } from "react";
import { DataTable } from "@/components/tables/DataTable";
import { API } from "@/lib/data-source";
import { formatCurrency } from "@/lib/utils";
import { PageSkeleton } from "@/components/shared/PageSkeleton";
import { showError, showSuccess } from "@/lib/toast-utils";
import { FileSpreadsheet } from "lucide-react";
import { exportARLedger } from "@/lib/export-utils";
import { useBranchStore } from "@/store/branch.store";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useRouter } from "next/navigation";
import { PageHeader } from "@/components/shared/PageHeader";

export default function ARLedgerPage() {
  const activeCurrency = useBranchStore((state) => state.activeCurrency);
  const router = useRouter();
  const [data, setData] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      try {
        const res = await API.getARLedger();
        setData(res);
      } catch (err: any) {
        showError(err.message || "Failed to load AR Ledger");
      } finally {
        setIsLoading(false);
      }
    };
    load();
  }, []);

  if (isLoading) return <PageSkeleton />;

  const totalOutstanding = data.reduce((sum, row) => sum + row.outstandingBalance, 0);

  const columns = [
    {
      accessorKey: "name",
      header: "Customer",
    },
    {
      accessorKey: "totalBilled",
      header: "Total Billed",
      cell: ({ row }: any) => formatCurrency(row.original.totalBilled),
    },
    {
      accessorKey: "totalPaid",
      header: "Total Paid",
      cell: ({ row }: any) => formatCurrency(row.original.totalPaid),
    },
    {
      accessorKey: "outstandingBalance",
      header: "Outstanding Balance",
      cell: ({ row }: any) => {
        const bal = row.original.outstandingBalance;
        return (
          <span className={bal > 0 ? "text-red-500 font-medium" : "text-emerald-500"}>
            {formatCurrency(bal)}
          </span>
        );
      },
    },
    {
      id: "actions",
      cell: ({ row }: any) => {
        return (
          <Button
            variant="ghost"
            onClick={() => router.push(`/customers/${row.original.id}`)}
          >
            View
          </Button>
        );
      },
    },
  ];

  return (
    <div className="space-y-6">

      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-tf-surface p-6 rounded-xl border border-tf-border shadow-sm">
        <PageHeader
          title="Accounts Receivable (AR)"
          description="View outstanding balances for all customers."
        />

        <div className="flex flex-col items-end gap-2">
          <p className="text-sm font-medium text-tf-text-secondary">Total Outstanding AR</p>
          <p className="text-3xl font-bold text-red-500">{formatCurrency(totalOutstanding)}</p>
          <Button
            variant="outline"
            size="sm"
            onClick={() => {
              exportARLedger(data, activeCurrency);
              showSuccess("AR Ledger exported");
            }}
            className="border-tf-border text-tf-text-secondary hover:bg-tf-surface-2"
          >
            <FileSpreadsheet className="mr-2 h-4 w-4" /> Export
          </Button>
        </div>
      </div>

      <div className="bg-tf-surface rounded-xl border border-tf-border overflow-hidden p-6">
        <DataTable
          columns={columns}
          data={data}
          searchKey="name"
          searchPlaceholder="Search customers..."
        />
      </div>
    </div>
  );
}
