const wait = async (ms: number): Promise<void> => await new Promise((res) => setTimeout(res, ms));

export default wait;
