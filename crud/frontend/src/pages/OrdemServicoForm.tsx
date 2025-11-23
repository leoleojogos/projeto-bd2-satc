import { useEffect, useState } from "react";
import { ordemServicoApi, type OrdemServico } from "../api/ordemServicoApi";
import { useNavigate, useParams } from "react-router";

export default function OrdemServicoForm() {
    const { id } = useParams();
    const navigate = useNavigate();

    const [form, setForm] = useState<OrdemServico>({
        id_veiculo: 0,
        id_mecanico: 0,
        data_entrada: "",
        data_saida: "",
        status: "",
        observacoes: "",
    });

    const atualizar = (e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value } = e.target;
        setForm((prev) => ({ ...prev, [name]: value }));
    };

    const salvar = async () => {
        if (id) {
            await ordemServicoApi.update(Number(id), form);
        } else {
            await ordemServicoApi.create(form);
        }
        navigate("/");
    };

    useEffect(() => {
        if (id) {
            ordemServicoApi.getById(Number(id)).then((res) => setForm(res.data));
        }
    }, [id]);

    return (
        <div className="p-8 max-w-xl mx-auto">
            <h1 className="text-3xl font-bold mb-6">
                {id ? "Editar Ordem" : "Nova Ordem"}
            </h1>

            <div className="flex flex-col gap-4">

                <Input label="Veículo" name="id_veiculo" value={form.id_veiculo} onChange={atualizar} />
                <Input label="Mecânico" name="id_mecanico" value={form.id_mecanico} onChange={atualizar} />

                <Input label="Data Entrada" type="date"
                    name="data_entrada" value={form.data_entrada ?? ""} onChange={atualizar} />

                <Input label="Data Saída" type="date"
                    name="data_saida" value={form.data_saida ?? ""} onChange={atualizar} />

                <Input label="Status" name="status" value={form.status ?? ""} onChange={atualizar} />

                <Input label="Observações" name="observacoes" value={form.observacoes ?? ""} onChange={atualizar} />
            </div>

            <div className="flex gap-3 mt-6">
                <button
                    onClick={salvar}
                    className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
                >
                    Salvar
                </button>

                <button
                    onClick={() => navigate("/")}
                    className="px-4 py-2 bg-gray-400 text-white rounded hover:bg-gray-500"
                >
                    Voltar
                </button>
            </div>
        </div>
    );
}

interface InputProps {
    label: string;
    name: string;
    value: any;
    onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
    type?: string;
}

function Input({ label, ...props }: InputProps) {
    return (
        <div className="flex flex-col">
            <label className="font-medium">{label}</label>
            <input
                {...props}
                className="border px-3 py-2 rounded mt-1 focus:ring focus:ring-blue-300"
            />
        </div>
    );
}
