const serializeBigInt = (data: any): any => {
    if (data === null || data === undefined) return data;

    if (typeof data === "bigint") {
        return data.toString();
    }

    if (Array.isArray(data)) {
        return data.map((item) => serializeBigInt(item));
    }

    if (typeof data === "object") {
        const result: any = {};
        for (const key in data) {
            if (Object.prototype.hasOwnProperty.call(data, key)) {
                result[key] = serializeBigInt(data[key]);
            }
        }
        return result;
    }

    return data;
};
export { serializeBigInt };
